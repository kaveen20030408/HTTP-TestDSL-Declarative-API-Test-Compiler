# Start the Spring Boot backend server

$BACKEND_DIR = "backend"

if (-not (Test-Path $BACKEND_DIR)) {
    Write-Host "Error: Backend directory not found" -ForegroundColor Red
    exit 1
}

Set-Location $BACKEND_DIR

# Check if JAR exists
$JAR_FILE = "target/testlang-demo-0.0.1-SNAPSHOT.jar"

if (-not (Test-Path $JAR_FILE)) {
    Write-Host "Backend JAR not found. Building with Maven..." -ForegroundColor Yellow
    
    if (-not (Get-Command mvn -ErrorAction SilentlyContinue)) {
        Write-Host "Error: Maven not installed. Please install Maven first." -ForegroundColor Red
        exit 1
    }
    
    mvn clean package -DskipTests
}

Write-Host "=== Starting Backend Server ===" -ForegroundColor Cyan
Write-Host "Server will be available at: http://localhost:8080" -ForegroundColor Green
Write-Host ""

java -jar $JAR_FILE
