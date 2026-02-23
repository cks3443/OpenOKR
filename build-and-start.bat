@echo off
chcp 65001 >nul
echo ========================================
echo OpenOKR Build and Start Script
echo ========================================
echo.

REM Set JAVA_HOME
set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_202"

echo [Step 1] Building project with Maven...
echo.
call mvn clean package -DskipTests

if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Build failed! Please check the error messages above.
    pause
    exit /b 1
)

echo.
echo [Step 2] Build completed successfully!
echo.
echo [Step 3] Starting all services...
echo.

REM Start services
call start-all.bat
