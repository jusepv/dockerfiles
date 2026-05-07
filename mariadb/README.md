# MariaDB Docker 구성

이 폴더는 MariaDB 데이터베이스를 Docker로 실행하기 위한 구성 파일들을 포함합니다.

## 실행권한

```bash
chmod +x /Users/sigi/kang_dev/dockerfiles/mariadb/backup.sh
chmod +x /Users/sigi/kang_dev/dockerfiles/mariadb/restore.sh
```

## 구성 요소

- `Dockerfile`: MariaDB 11.2 기반 커스텀 이미지
- `docker-compose.yml`: MariaDB와 phpMyAdmin 서비스 구성
- `backup.sh`: 데이터베이스 백업 스크립트
- `restore.sh`: 데이터베이스 복원 스크립트

## 디렉토리 구조

```
mariadb/
├── Dockerfile
├── docker-compose.yml
├── backup.sh
├── restore.sh
├── data/                # MariaDB 데이터 영구 저장
├── backups/            # 백업 파일 저장
├── init-scripts/       # 초기화 SQL 스크립트
└── config/             # 설정 파일 (옵션)
```

## 사용법

### 1. 서비스 시작

```bash
# 서비스 빌드 및 시작
docker-compose up -d

# 로그 확인
docker-compose logs -f mariadb
```

### 2. 데이터베이스 접속

#### 명령줄에서 접속

```bash
# 컨테이너 내부로 접속
docker exec -it mariadb-db mysql -uroot -proot1234!

# 또는 일반 사용자로 접속
docker exec -it mariadb-db mysql -uadmin -padmin1234! -D mariadb
```

#### phpMyAdmin으로 접속

브라우저에서 `http://localhost:48082` 접속

- **서버**: mariadb
- **사용자명**: root (또는 admin)
- **비밀번호**: root1234! (또는 admin1234!)

### 3. 데이터베이스 백업

#### 전체 백업

```bash
# 모든 데이터베이스 백업
./backup.sh
```

#### 특정 데이터베이스 백업

```bash
# 특정 데이터베이스만 백업
./backup.sh mariadb
```

백업 파일은 `backups/` 디렉토리에 압축되어 저장되며, 30일 이상 된 백업은 자동으로 삭제됩니다.

### 4. 데이터베이스 복원

#### 전체 복원

```bash
# 모든 데이터베이스 복원
./restore.sh backups/mariadb_all_20241209_120000.sql.gz
```

#### 특정 데이터베이스 복원

```bash
# 특정 데이터베이스만 복원
./restore.sh backups/mariadb_20241209_120000.sql.gz mariadb
```

### 5. 데이터베이스 관리

#### 데이터베이스 생성

```sql
CREATE DATABASE mydb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 사용자 생성 및 권한 부여

```sql
CREATE USER 'newuser'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON mydb.* TO 'newuser'@'%';
FLUSH PRIVILEGES;
```

#### 데이터베이스 목록 확인

```sql
SHOW DATABASES;
```

#### 테이블 목록 확인

```sql
USE mariadb;
SHOW TABLES;
```

## 환경 변수

docker-compose.yml에서 다음 환경 변수를 수정할 수 있습니다:

```yaml
environment:
  MYSQL_ROOT_PASSWORD: root1234! # root 사용자 비밀번호
  MYSQL_DATABASE: mariadb # 초기 데이터베이스명
  MYSQL_USER: admin # 일반 사용자명
  MYSQL_PASSWORD: admin1234! # 일반 사용자 비밀번호
  TZ: Asia/Seoul # 시간대
```

## 포트

- **MariaDB**: 3306
- **phpMyAdmin**: 48082

## 볼륨

- `./data`: MariaDB 데이터 파일 (영구 저장)
- `./backups`: 백업 파일
- `./init-scripts`: 초기화 SQL 스크립트 (.sql, .sql.gz)

## 초기화 스크립트

`init-scripts/` 폴더에 SQL 파일을 배치하면 컨테이너 최초 실행 시 자동으로 실행됩니다.

```bash
mkdir -p init-scripts
echo "CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(100));" > init-scripts/01-init.sql
```

## 설정 파일

커스텀 설정이 필요한 경우 `config/my.cnf` 파일을 생성하고 docker-compose.yml의 주석을 해제하세요.

```ini
[mysqld]
max_connections = 500
innodb_buffer_pool_size = 1G
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[client]
default-character-set = utf8mb4
```

## 성능 튜닝

docker-compose.yml의 command 섹션에서 MariaDB 파라미터를 조정할 수 있습니다:

```yaml
command: >
  --character-set-server=utf8mb4
  --collation-server=utf8mb4_unicode_ci
  --max-connections=200
  --innodb-buffer-pool-size=256M
  --innodb-log-file-size=64M
```

## 헬스체크

컨테이너의 상태는 다음 명령으로 확인할 수 있습니다:

```bash
docker ps
docker inspect mariadb-db | grep -A 10 Health
```

## 문제 해결

### 컨테이너가 시작되지 않는 경우

```bash
# 로그 확인
docker-compose logs mariadb

# 데이터 디렉토리 권한 문제일 경우
sudo chown -R 999:999 ./data
```

### 비밀번호 변경

```bash
# 컨테이너 접속
docker exec -it mariadb-db mysql -uroot -proot1234!

# 비밀번호 변경
ALTER USER 'root'@'%' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
```

### 연결 문제

```bash
# 네트워크 확인
docker network inspect infra_network

# 포트 확인
netstat -an | grep 3306
```

## 주의사항

1. **비밀번호 보안**: 프로덕션 환경에서는 강력한 비밀번호를 사용하고 환경 변수 파일(.env)로 관리하세요.
2. **백업**: 중요한 데이터는 정기적으로 백업하세요.
3. **데이터 영구성**: `./data` 디렉토리를 삭제하면 모든 데이터가 손실됩니다.
4. **포트 충돌**: 3306 포트가 이미 사용 중이면 docker-compose.yml에서 다른 포트로 변경하세요.

## 참고 자료

- [MariaDB 공식 문서](https://mariadb.com/kb/en/documentation/)
- [MariaDB Docker Hub](https://hub.docker.com/_/mariadb)
- [phpMyAdmin 공식 문서](https://docs.phpmyadmin.net/)
