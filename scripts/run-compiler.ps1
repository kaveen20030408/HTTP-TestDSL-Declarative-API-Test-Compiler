# Run the TestLang++ compiler on a .test file

param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "output/GeneratedTests.java"
)

if (-not (Test-Path $InputFile)) {
    Write-Host "Error: Input file '$InputFile' not found" -ForegroundColor Red
    exit 1
}

# Ensure output directory exists
$outputDir = Split-Path $OutputFile -Parent
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Paths
$BUILD_DIR = "build"
$CUP_RUNTIME = "lib/java-cup-11b-runtime.jar"

if (-not (Test-Path $BUILD_DIR)) {
    Write-Host "Build directory not found. Run .\scripts\compile.ps1 first" -ForegroundColor Red
    exit 1
}

Write-Host "=== Running TestLang++ Compiler ===" -ForegroundColor Cyan
Write-Host "Input:  $InputFile" -ForegroundColor White
Write-Host "Output: $OutputFile" -ForegroundColor White
Write-Host ""

java -cp "$BUILD_DIR;$CUP_RUNTIME" compiler.TestLangCompiler $InputFile $OutputFile

Write-Host ""
Write-Host "Generated: $OutputFile" -ForegroundColor Green
