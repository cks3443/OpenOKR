@echo off
chcp 65001 >nul
echo ========================================
echo OpenOKR Local Environment Setup
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [WARNING] This script requires Administrator privileges to modify hosts file.
    echo Please run as Administrator.
    echo.
    pause
    exit /b 1
)

echo This script will:
echo 1. Add Zookeeper and PostgreSQL host mappings to hosts file
echo 2. Check Docker status
echo.

set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"

if not exist "%HOSTS_FILE%" (
    echo [ERROR] Hosts file not found: %HOSTS_FILE%
    echo Please ensure you are running on a standard Windows installation.
    pause
    exit /b 1
)

REM Check if entries already exist
findstr /C:"zkserver1" "%HOSTS_FILE%" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Adding zkserver1 to hosts file...
    echo 127.0.0.1 zkserver1 >> "%HOSTS_FILE%"
) else (
    echo zkserver1 already exists in hosts file.
)

findstr /C:"pgserver" "%HOSTS_FILE%" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Adding pgserver to hosts file...
    echo 127.0.0.1 pgserver >> "%HOSTS_FILE%"
) else (
    echo pgserver already exists in hosts file.
)

echo.
echo ========================================
echo Hosts file configuration completed!
echo ========================================
echo.
echo Next steps:
echo 1. Start Zookeeper: docker run -d --name zookeeper -p 2181:2181 zookeeper:3.4
echo 2. Start PostgreSQL: docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=okr_dev postgres:9.6
echo 3. Run start-all.bat to start OpenOKR services
echo.
pause
