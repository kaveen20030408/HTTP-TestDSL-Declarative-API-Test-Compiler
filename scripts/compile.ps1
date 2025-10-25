# Compile the TestLang++ compiler: Scanner + Parser + Code Generator

Write-Host "=== Compiling TestLang++ Compiler ===" -ForegroundColor Cyan

# Paths
$LIB_DIR = "lib"
$BUILD_DIR = "build"
$JFLEX_JAR = "$LIB_DIR/jflex-full-1.9.1.jar"
$CUP_JAR = "$LIB_DIR/java-cup-11b.jar"
$CUP_RUNTIME = "$LIB_DIR/java-cup-11b-runtime.jar"

# Check if dependencies exist
if (-not (Test-Path $JFLEX_JAR) -or -not (Test-Path $CUP_JAR)) {
    Write-Host "Dependencies not found. Libraries are present in lib/" -ForegroundColor Yellow
}

# Create build directory
if (-not (Test-Path $BUILD_DIR)) {
    New-Item -ItemType Directory -Path $BUILD_DIR | Out-Null
}

Write-Host "[1/5] Generating Scanner with JFlex..." -ForegroundColor Yellow
java -cp "$JFLEX_JAR;$CUP_RUNTIME" jflex.Main -d scanner scanner/lexer.flex

Write-Host "[2/5] Generating Parser with CUP..." -ForegroundColor Yellow
java -cp "$CUP_JAR;$CUP_RUNTIME" java_cup.Main -destdir parser -parser Parser -symbols sym parser/parser.cup

Write-Host "[3/5] Compiling AST classes..." -ForegroundColor Yellow
$astFiles = Get-ChildItem -Path ast -Filter *.java | ForEach-Object { $_.FullName }
javac -d $BUILD_DIR -cp $CUP_RUNTIME $astFiles

Write-Host "[4/5] Compiling Scanner and Parser..." -ForegroundColor Yellow
$scannerFiles = Get-ChildItem -Path scanner -Filter *.java | ForEach-Object { $_.FullName }
$parserFiles = Get-ChildItem -Path parser -Filter *.java | ForEach-Object { $_.FullName }
javac -d $BUILD_DIR -cp "$CUP_RUNTIME;$BUILD_DIR" $scannerFiles $parserFiles

Write-Host "[5/5] Compiling Code Generator and Compiler..." -ForegroundColor Yellow
$codegenFiles = Get-ChildItem -Path codegen -Filter *.java | ForEach-Object { $_.FullName }
$compilerFiles = Get-ChildItem -Path compiler -Filter *.java | ForEach-Object { $_.FullName }
javac -d $BUILD_DIR -cp "$CUP_RUNTIME;$BUILD_DIR" $codegenFiles $compilerFiles

Write-Host "Compilation successful! Output in $BUILD_DIR/" -ForegroundColor Green
