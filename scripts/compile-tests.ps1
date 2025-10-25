# Compile the generated test file with JUnit dependencies

Write-Host "=== Compiling Generated Tests ===" -ForegroundColor Cyan

# Paths
$JUNIT_DIR = "lib\junit"
$OUTPUT_DIR = "output"
$BUILD_DIR = "build\tests"

# Build classpath for JUnit
$JUNIT_JARS = Get-ChildItem -Path $JUNIT_DIR -Filter *.jar | ForEach-Object { $_.FullName }
$CLASSPATH = ($JUNIT_JARS -join ";")

# Create build directory for tests
if (-not (Test-Path $BUILD_DIR)) {
    New-Item -ItemType Directory -Path $BUILD_DIR -Force | Out-Null
}

Write-Host "Compiling GeneratedTests.java..." -ForegroundColor Yellow
javac -d $BUILD_DIR -cp $CLASSPATH "$OUTPUT_DIR\GeneratedTests.java"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Test compilation successful! Output in $BUILD_DIR/" -ForegroundColor Green
} else {
    Write-Host "Test compilation failed!" -ForegroundColor Red
    exit 1
}
