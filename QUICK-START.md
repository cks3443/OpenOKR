# OpenOKR Quick Start Guide

## 사전 요구사항

1. **Java 8** 설치 (`C:\Program Files\Java\jdk1.8.0_202`)
2. **Maven** 설치
3. **Docker Desktop** 설치 및 실행

## 빠른 시작

### 1. 초기 설정 (최초 1회만 실행)

관리자 권한으로 CMD를 실행한 후:
```cmd
setup-local-env.bat
```

이 스크립트는 hosts 파일에 다음 항목을 추가합니다 (start-all/manual 방식에서만 필요):
- `127.0.0.1 zkserver1`
- `127.0.0.1 pgserver`

`docker compose`로 배포하는 경우에는 hosts 파일 설정이 필요 없습니다.

### 2. 서비스 시작 (Docker Compose 권장)

```cmd
docker compose up --build -d
```

이 명령어 하나로 다음이 모두 실행됩니다:
1. Docker 이미지 빌드 (`okr-service`, `okr-web`, `okr-m-web`)
2. Zookeeper, PostgreSQL 컨테이너 시작
3. okr-service (Dubbo Provider) 시작
4. okr-web (Web Application) 시작
5. okr-m-web (Mobile Web) 시작

기존 방식(`start-all.bat`)도 계속 사용 가능합니다.

### 3. 서비스 중지 (Compose)

```cmd
docker compose down
```

### 4. 빌드 후 시작

```cmd
build-and-start.bat
```

Maven 빌드 후 자동으로 서비스를 시작합니다.

> 참고: 현재 사용 중인 Java가 9+이면 `okr-api` 컴파일 단계에서 아래 오류가 발생할 수 있습니다.
>
> ```
> Unable to make field private ... JavacProcessingEnvironment.discoveredProcs accessible
> ```
>
> 이 경우 JDK 8 환경에서 빌드하거나, Maven을 실행할 때 `JAVA_HOME`을 JDK 8로 설정하세요.

예시(Windows PowerShell):
```powershell
$env:JAVA_HOME = 'C:\Program Files\Java\jdk1.8.0_202'
$env:Path = "$env:JAVA_HOME\\bin;$env:Path"
mvn.cmd clean package -DskipTests
```

## 서비스 포트

| 서비스 | 포트 | URL |
|--------|------|-----|
| okr-web | 8892 | http://localhost:8892 |
| okr-m-web | 8893 | http://localhost:8893 |
| Zookeeper | 2181 | localhost:2181 |
| PostgreSQL | 5432 | localhost:5432 |

## 스크립트 목록

| 스크립트 | 설명 |
|----------|------|
| `setup-local-env.bat` | 로컬 개발 환경 설정 (관리자 권한 필요) |
| `start-all.bat` | 모든 서비스 시작 |
| `stop-all.bat` | 모든 서비스 중지 |
| `build-and-start.bat` | Maven 빌드 후 서비스 시작 |

## Docker 컨테이너 관리

```cmd
# 컨테이너 상태 확인
docker ps

# 컨테이너 수동 시작
docker-compose up -d

# 컨테이너 중지
docker-compose down

# 컨테이너 로그 확인
docker logs okr-zookeeper
docker logs okr-postgres
```

## 문제 해결

### Zookeeper 연결 실패
```
java.nio.channels.UnresolvedAddressException
```
→ `setup-local-env.bat`을 관리자 권한으로 실행했는지 확인

### PostgreSQL 연결 실패
→ Docker 컨테이너가 실행 중인지 확인: `docker ps`

### JAR 파일 없음
→ 프로젝트 빌드: `docker compose up --build -d`
