@echo off
chcp 65001 >nul
echo ========================================
echo OpenOKR Service Stop Script
echo ========================================
echo.

echo Stopping all OpenOKR services...

REM Kill Java processes for OpenOKR services
taskkill /FI "WINDOWTITLE eq OKR-Service*" /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq OKR-Web*" /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq OKR-M-Web*" /F >nul 2>&1

echo Java services stopped.

REM Ask if user wants to stop Docker containers
echo.
set /p STOP_DOCKER="Stop Docker containers? (Y/N): "
if /i "%STOP_DOCKER%"=="Y" (
    echo Stopping Docker containers...
    docker-compose down
    echo Docker containers stopped.
)

echo.
echo All services stopped.
echo.
pause
