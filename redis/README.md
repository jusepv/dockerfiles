# Redis Docker Setup

이 디렉토리에는 Redis를 Docker로 실행하기 위한 설정 파일들이 포함되어 있습니다.

## 파일 구성

- `Dockerfile`: Redis Docker 이미지 빌드를 위한 파일
- `redis.conf`: Redis 서버 설정 파일
- `docker-compose.yml`: Docker Compose를 사용한 편리한 실행을 위한 파일

## 사용법

### 1. Docker Compose 사용 (권장)

```bash
# Redis 컨테이너 시작
docker-compose up -d

# Redis 컨테이너 중지
docker-compose down

# 로그 확인
docker-compose logs redis
```

### 2. Docker 명령어 직접 사용

```bash
# 이미지 빌드
docker build -t my-redis .

# 컨테이너 실행
docker run -d \
  --name redis-server \
  -p 6379:6379 \
  -v redis_data:/data \
  my-redis
```

### 3. Redis 연결 테스트

```bash
# Redis CLI로 연결
docker exec -it redis-server redis-cli

# 또는 로컬에서 redis-cli가 설치되어 있다면
redis-cli -h localhost -p 6379
```

## 설정 변경

`redis.conf` 파일을 수정하여 Redis 설정을 변경할 수 있습니다. 주요 설정 항목:

- **메모리 제한**: `maxmemory 256mb`
- **비밀번호 설정**: `requirepass your_password_here` (주석 해제 후 사용)
- **데이터 지속성**: `save` 및 `appendonly` 설정
- **네트워크 바인딩**: `bind 0.0.0.0`

설정 변경 후 컨테이너를 재시작해야 합니다:

```bash
docker-compose restart redis
```

## 데이터 지속성

- Redis 데이터는 Docker 볼륨 `redis_data`에 저장됩니다
- 컨테이너를 삭제해도 데이터는 유지됩니다
- 데이터를 완전히 삭제하려면: `docker volume rm redis_redis_data`

## 보안 고려사항

프로덕션 환경에서 사용 시:

1. `redis.conf`에서 `requirepass`를 설정하여 비밀번호를 활성화하세요
2. `protected-mode yes`로 변경하세요
3. 필요에 따라 `bind` 설정을 조정하세요
