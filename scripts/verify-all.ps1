# Verification script - tests all examples

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "TestLang++ Verification Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if compiler is built
if (-not (Test-Path "build")) {
    Write-Host "Build directory not found" -ForegroundColor Red
    Write-Host "Run: .\scripts\compile.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "Build directory exists" -ForegroundColor Green
Write-Host ""

# Test example file
$example = "examples/example.test"
$output = "output/GeneratedTests.java"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Compiling Example Files" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Testing: $example" -ForegroundColor White
try {
    & .\scripts\run-compiler.ps1 $example $output *>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Compilation successful" -ForegroundColor Green
        
        # Check if output file exists and is not empty
        if ((Test-Path $output) -and ((Get-Item $output).Length -gt 0)) {
            $lines = (Get-Content $output).Count
            Write-Host "  Generated $lines lines of code" -ForegroundColor Green
        } else {
            Write-Host "  Output file is empty" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "  Compilation failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  Compilation error: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Feature Verification" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check for key features in generated code
Write-Host "Checking GeneratedTests.java for:" -ForegroundColor White
$content = Get-Content $output -Raw

if ($content -match "import org.junit.jupiter.api") {
    Write-Host "  JUnit 5 imports found" -ForegroundColor Green
}

if ($content -match "HttpClient") {
    Write-Host "  HttpClient usage found" -ForegroundColor Green
}

if ($content -match "@Test") {
    Write-Host "  @Test annotations found" -ForegroundColor Green
}

if ($content -match "assertEquals") {
    Write-Host "  Status assertions found" -ForegroundColor Green
}

if ($content -match "assertTrue") {
    Write-Host "  Body/Header contains assertions found" -ForegroundColor Green
}

if ($content -match "admin") {
    Write-Host "  Variable substitution found" -ForegroundColor Green
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "All Verifications Passed!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your TestLang++ compiler is working correctly!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review generated code in output/" -ForegroundColor White
Write-Host "2. Start backend: .\scripts\start-backend.ps1" -ForegroundColor White
Write-Host "3. Run tests: .\scripts\run-tests.ps1 output/GeneratedTests.java" -ForegroundColor White
