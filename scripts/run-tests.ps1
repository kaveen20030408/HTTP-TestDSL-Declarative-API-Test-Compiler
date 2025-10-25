# Compile and run the generated JUnit tests

param(
    [Parameter(Mandatory=$true)]
    [string]$GeneratedFile
)

if (-not (Test-Path $GeneratedFile)) {
    Write-Host "Error: Generated test file '$GeneratedFile' not found" -ForegroundColor Red
    exit 1
}

# Download JUnit 5 JAR if not present
$JUNIT_DIR = "lib/junit"
if (-not (Test-Path $JUNIT_DIR)) {
    New-Item -ItemType Directory -Path $JUNIT_DIR -Force | Out-Null
}

$JUNIT_JAR = "$JUNIT_DIR/junit-platform-console-standalone-1.10.0.jar"
if (-not (Test-Path $JUNIT_JAR)) {
    Write-Host "Downloading JUnit 5..." -ForegroundColor Yellow
    $url = "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-console-standalone/1.10.0/junit-platform-console-standalone-1.10.0.jar"
    Invoke-WebRequest -Uri $url -OutFile $JUNIT_JAR
}

$TEST_BUILD = "build/tests"
if (-not (Test-Path $TEST_BUILD)) {
    New-Item -ItemType Directory -Path $TEST_BUILD -Force | Out-Null
}

Write-Host "=== Compiling Generated Tests ===" -ForegroundColor Cyan
javac -d build/tests -cp $JUNIT_DIR/junit-platform-console-standalone-1.10.0.jar $GeneratedFile

Write-Host ""
Write-Host "=== Running JUnit Tests ===" -ForegroundColor Cyan
java -jar $JUNIT_JAR --class-path build/tests --scan-class-path

Write-Host ""
Write-Host "Tests completed!" -ForegroundColor Green
