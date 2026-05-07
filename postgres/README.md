# PostgreSQL Docker 구성

이 폴더는 PostgreSQL 데이터베이스를 Docker로 실행하기 위한 구성 파일들을 포함합니다.

## 실행권한

```
chmod +x /Users/sigi/kang_dev/dockerfiles/postgres/backup.sh
chmod +x /Users/sigi/kang_dev/dockerfiles/postgres/restore.sh
```

## 구성 요소

- `Dockerfile`: PostgreSQL 16 Alpine 기반 커스텀 이미지
- `docker-compose.yml`: PostgreSQL과 pgAdmin 서비스 구성
- `backup.sh`: 데이터베이스 백업 스크립트
- `restore.sh`: 데이터베이스 복원 스크립트

## 디렉토리 구조

```
postgres/
├── Dockerfile
├── docker-compose.yml
├── backup.sh
├── restore.sh
├── data/                # PostgreSQL 데이터 영구 저장
├── backups/            # 백업 파일 저장
└── init-scripts/       # 초기화 SQL 스크립트
```

## 사용법

### 1. 서비스 시작

```bash
# 서비스 빌드 및 시작
docker-compose up -d

# 로그 확인
docker-compose logs -f postgres
```

### 2. 데이터베이스 접속

#### 명령줄에서 접속

```bash
# 컨테이너 내부로 접속
docker exec -it postgres-db psql -U admin -d postgres

# 또는 호스트에서 직접 접속
psql -h localhost -p 5432 -U admin -d postgres
```

#### pgAdmin으로 접속

- URL: http://localhost:48080
- 이메일: admin@admin.com
- 비밀번호: admin1234!

pgAdmin에서 새 서버 추가:

- 호스트: postgres (또는 localhost)
- 포트: 5432
- 사용자명: admin
- 비밀번호: admin1234!

### 3. 백업 및 복원

#### 백업

```bash
# 실행 권한 부여 (최초 1회)
chmod +x backup.sh

# 전체 데이터베이스 백업
./backup.sh

# 특정 데이터베이스 백업
./backup.sh mydatabase
```

#### 복원

```bash
# 실행 권한 부여 (최초 1회)
chmod +x restore.sh

# 백업 파일 복원
./restore.sh postgres_backup_20231207_143022.sql.gz

# 특정 데이터베이스로 복원
./restore.sh postgres_backup_20231207_143022.sql.gz mydatabase
```

### 4. 서비스 관리

```bash
# 서비스 중지
docker-compose down

# 서비스 중지 및 볼륨 삭제 (데이터 완전 삭제)
docker-compose down -v

# 서비스 재시작
docker-compose restart

# 이미지 재빌드
docker-compose build --no-cache
```

## 연결 정보

- **데이터베이스 호스트**: localhost
- **포트**: 5432
- **사용자명**: admin
- **비밀번호**: admin1234!
- **기본 데이터베이스**: postgres

## 보안 주의사항

프로덕션 환경에서는 다음 사항을 고려하세요:

1. 강력한 비밀번호 사용
2. 환경 변수나 Docker secrets를 통한 비밀번호 관리
3. 방화벽 규칙 설정
4. SSL/TLS 연결 활성화
5. 정기적인 백업 및 보안 업데이트

## 문제 해결

### 컨테이너가 시작되지 않는 경우

```bash
# 로그 확인
docker-compose logs postgres

# 데이터 디렉토리 권한 확인
ls -la data/
```

### 연결 거부 오류

```bash
# 컨테이너 상태 확인
docker-compose ps

# 헬스체크 상태 확인
docker inspect postgres-db | grep Health -A 10
```
