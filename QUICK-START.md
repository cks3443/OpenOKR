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

이 스크립트는 hosts 파일에 다음 항목을 추가합니다:
- `127.0.0.1 zkserver1`
- `127.0.0.1 pgserver`

### 2. 서비스 시작

```cmd
start-all.bat
```

이 명령어 하나로 다음이 자동 실행됩니다:
1. Docker 컨테이너 시작 (Zookeeper, PostgreSQL)
2. okr-service (Dubbo Provider) 시작
3. okr-web (Web Application) 시작
4. okr-m-web (Mobile Web) 시작

### 3. 서비스 중지

```cmd
stop-all.bat
```

### 4. 빌드 후 시작

```cmd
build-and-start.bat
```

Maven 빌드 후 자동으로 서비스를 시작합니다.

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
→ 프로젝트 빌드: `mvn clean package -DskipTests`
