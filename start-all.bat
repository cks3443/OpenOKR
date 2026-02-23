@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
echo ========================================
echo OpenOKR Service Startup Script
echo ========================================
echo.

REM Set JAVA_HOME
set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_202"

REM Check if hosts file has required entries
findstr /C:"zkserver1" C:\Windows\System32\drivers\etc\hosts >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [WARNING] zkserver1 not found in hosts file!
    echo Please run setup-local-env.bat as Administrator first.
    echo.
)

findstr /C:"pgserver" C:\Windows\System32\drivers\etc\hosts >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [WARNING] pgserver not found in hosts file!
    echo Please run setup-local-env.bat as Administrator first.
    echo.
)

REM Check if Docker containers are running
docker ps | findstr okr-zookeeper >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [INFO] Starting Docker containers (Zookeeper, PostgreSQL)...
    docker-compose up -d
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Failed to start Docker containers!
        echo Please make sure Docker Desktop is running.
        pause
        exit /b 1
    )
    echo [INFO] Waiting for services to initialize...
    timeout /t 10 /nobreak >nul
)

REM Check if JAR files exist
if not exist "okr-service\target\okr-service.jar" (
    echo [ERROR] okr-service.jar not found!
    echo Please build the project first: mvn clean package -DskipTests
    pause
    exit /b 1
)

if not exist "okr-web\target\okr-web.jar" (
    echo [ERROR] okr-web.jar not found!
    echo Please build the project first: mvn clean package -DskipTests
    pause
    exit /b 1
)

if not exist "okr-m-web\target\okr-m-web.jar" (
    echo [ERROR] okr-m-web.jar not found!
    echo Please build the project first: mvn clean package -DskipTests
    pause
    exit /b 1
)

echo.
echo [1/3] Starting okr-service (Dubbo Provider)...
cd okr-service
start "OKR-Service" cmd /c ""!JAVA_HOME!\bin\java.exe" -jar -Xms128m -Xmx512m target/okr-service.jar"
cd ..
timeout /t 15 /nobreak >nul

echo [2/3] Starting okr-web (Web Application - Port 8892)...
cd okr-web
start "OKR-Web" cmd /c ""!JAVA_HOME!\bin\java.exe" -jar -Xms128m -Xmx512m target/okr-web.jar"
cd ..
timeout /t 5 /nobreak >nul

echo [3/3] Starting okr-m-web (Mobile Web - Port 8893)...
cd okr-m-web
start "OKR-M-Web" cmd /c ""!JAVA_HOME!\bin\java.exe" -jar -Xms128m -Xmx512m target/okr-m-web.jar"
cd ..

echo.
echo ========================================
echo All services started!
echo ========================================
echo.
echo Services:
echo   - Zookeeper  : localhost:2181
echo   - PostgreSQL : localhost:5432
echo   - okr-service: Dubbo Provider (Port 20254)
echo   - okr-web    : http://localhost:8892
echo   - okr-m-web  : http://localhost:8893
echo.
echo Press any key to exit this window...
pause >nul
