@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
echo ========================================
echo OpenOKR Service Startup Script
echo ========================================
echo.

REM Set JAVA_HOME
set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_202"
set "JAVA_EXE=!JAVA_HOME!\bin\java.exe"

if not exist "!JAVA_EXE!" (
    echo [ERROR] JAVA executable not found: !JAVA_EXE!
    echo Please update JAVA_HOME in start-all.bat.
    pause
    exit /b 1
)

REM Check if hosts file has required entries
set "HOSTS_CHECK_OK=1"

findstr "zkserver1" "C:\Windows\System32\drivers\etc\hosts" >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo [WARNING] zkserver1 not found in hosts file!
    echo Please run setup-local-env.bat as Administrator first.
    set "HOSTS_CHECK_OK=0"
    echo.
)

findstr "pgserver" "C:\Windows\System32\drivers\etc\hosts" >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo [WARNING] pgserver not found in hosts file!
    echo Please run setup-local-env.bat as Administrator first.
    set "HOSTS_CHECK_OK=0"
    echo.
)

if !HOSTS_CHECK_OK! neq 1 (
    echo [ERROR] Required hosts entries are missing. Fix hosts file and retry.
    echo.
    exit /b 1
)

REM Check if Docker containers are running
docker ps > temp_docker_ps.txt 2>&1
findstr okr-zookeeper temp_docker_ps.txt >nul
set "DOCKER_OKR_ZK_RUNNING=!ERRORLEVEL!"
del temp_docker_ps.txt 2>nul
if !DOCKER_OKR_ZK_RUNNING! neq 0 (
    echo [INFO] Starting Docker containers ^(Zookeeper, PostgreSQL^)...
    docker-compose up -d
    if !ERRORLEVEL! neq 0 (
        echo [ERROR] Failed to start Docker containers!
        echo Please make sure Docker Desktop is running.
        pause
        exit /b 1
    )
)

echo [INFO] Verifying local services are listening before starting applications...
call :wait_for_port 2181 20 Zookeeper
if !ERRORLEVEL! neq 0 (
    exit /b 1
)
call :wait_for_port 5432 20 PostgreSQL
if !ERRORLEVEL! neq 0 (
    exit /b 1
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
start "OKR-Service" "!JAVA_EXE!" -jar -Xms128m -Xmx512m target/okr-service.jar
cd ..
timeout /t 8 /nobreak >nul
call :wait_for_port 20254 15 okr-service
if !ERRORLEVEL! neq 0 (
    exit /b 1
)

echo [2/3] Starting okr-web (Web Application - Port 8892)...
cd okr-web
start "OKR-Web" "!JAVA_EXE!" -jar -Xms128m -Xmx512m target/okr-web.jar
cd ..
call :wait_for_port 8892 30 okr-web
if !ERRORLEVEL! neq 0 (
    exit /b 1
)

echo [3/3] Starting okr-m-web (Mobile Web - Port 8893)...
cd okr-m-web
start "OKR-M-Web" "!JAVA_EXE!" -jar -Xms128m -Xmx512m target/okr-m-web.jar
cd ..
call :wait_for_port 8893 20 okr-m-web
if !ERRORLEVEL! neq 0 (
    exit /b 1
)

:wait_for_port
set "PORT=%~1"
set "MAX_WAIT_SECONDS=%~2"
set "SERVICE_NAME=%~3"

for /L %%I in (1,1,%MAX_WAIT_SECONDS%) do (
    timeout /t 1 /nobreak >nul
    netstat -ano | findstr /C:":%PORT% " >nul 2>&1
    if !ERRORLEVEL! == 0 (
        echo [INFO] %SERVICE_NAME% is now listening on port %PORT%
        goto :port_check_done
    )
)

echo [ERROR] %SERVICE_NAME% did not start on port %PORT% within %MAX_WAIT_SECONDS% seconds.
echo [HINT] Check startup errors in console windows (OKR-Service, OKR-Web, OKR-M-Web)
exit /b 1

:port_check_done
exit /b 0

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
