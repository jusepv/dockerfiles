# MongoDB Docker Setup

이 디렉토리에는 MongoDB를 Docker로 실행하기 위한 설정 파일들이 포함되어 있습니다.

## 파일 구성

- `Dockerfile`: MongoDB Docker 이미지 빌드를 위한 파일
- `docker-compose.yml`: Docker Compose를 사용한 편리한 실행을 위한 파일

## 디렉토리 구조

```
mongo/
├── Dockerfile
├── docker-compose.yml
├── data/                # MongoDB 데이터 영구 저장
│   ├── db/             # 데이터베이스 파일
│   └── configdb/       # 설정 데이터
├── backups/            # 백업 파일 저장
└── init-scripts/       # 초기화 스크립트 (옵션)
```

## 사용법

### 1. Docker Compose 사용 (권장)

```bash
# MongoDB 컨테이너 시작
docker-compose up -d

# MongoDB 컨테이너 중지
docker-compose down

# 로그 확인
docker-compose logs -f mongo-db

# 서비스 재시작
docker-compose restart mongo-db
```

### 2. 데이터베이스 접속

#### 명령줄에서 접속

```bash
# 컨테이너 내부로 접속
docker exec -it mongo-db mongosh -u admin -p admin1234! --authenticationDatabase admin

# 또는 호스트에서 직접 접속 (mongosh 설치 필요)
mongosh "mongodb://admin:admin1234!@localhost:27017/admin"
```

#### Mongo Express로 접속 (웹 UI)

- URL: http://localhost:48081
- 사용자명: admin
- 비밀번호: admin1234!

### 3. 백업 및 복원

#### 백업

```bash
# 전체 데이터베이스 백업
docker exec mongo-db mongodump \
  --username admin \
  --password admin1234! \
  --authenticationDatabase admin \
  --out /backup/backup_$(date +%Y%m%d_%H%M%S)

# 특정 데이터베이스 백업
docker exec mongo-db mongodump \
  --username admin \
  --password admin1234! \
  --authenticationDatabase admin \
  --db mydatabase \
  --out /backup/backup_$(date +%Y%m%d_%H%M%S)
```

#### 복원

```bash
# 전체 데이터베이스 복원
docker exec mongo-db mongorestore \
  --username admin \
  --password admin1234! \
  --authenticationDatabase admin \
  /backup/backup_20231207_143022

# 특정 데이터베이스 복원
docker exec mongo-db mongorestore \
  --username admin \
  --password admin1234! \
  --authenticationDatabase admin \
  --db mydatabase \
  /backup/backup_20231207_143022/mydatabase
```

### 4. Docker 명령어 직접 사용

```bash
# 이미지 빌드
docker build -t my-mongodb .

# 컨테이너 실행
docker run -d \
  --name mongo-db \
  -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=admin1234! \
  -v mongodb_data:/data/db \
  my-mongodb
```

## 연결 정보

- **호스트**: localhost
- **포트**: 27017
- **사용자명**: admin
- **비밀번호**: admin1234!
- **인증 데이터베이스**: admin

### 연결 문자열

```
mongodb://admin:admin1234!@localhost:27017/admin
```

## Replica Set 설정

현재 MongoDB는 단일 노드 Replica Set (`rs0`)으로 구성되어 있습니다.

### Replica Set 초기화

최초 실행 시 Replica Set을 초기화해야 합니다:

```bash
# MongoDB에 접속
docker exec -it mongo-db mongosh -u admin -p admin1234! --authenticationDatabase admin

# Replica Set 초기화
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "localhost:27017" }
  ]
})

# Replica Set 상태 확인
rs.status()
```

### Replica Set 연결 문자열

Replica Set으로 연결할 때는 다음과 같이 사용:

```
mongodb://admin:admin1234!@localhost:27017/admin?replicaSet=rs0
```

## 기본 MongoDB 명령어

```javascript
// 데이터베이스 목록 확인
show dbs

// 데이터베이스 선택/생성
use mydatabase

// 컬렉션 목록 확인
show collections

// 사용자 생성
db.createUser({
  user: "myuser",
  pwd: "mypassword",
  roles: [{ role: "readWrite", db: "mydatabase" }]
})

// 데이터 삽입
db.mycollection.insertOne({ name: "John", age: 30 })

// 데이터 조회
db.mycollection.find()

// 데이터베이스 통계
db.stats()
```

## 서비스 관리

```bash
# 서비스 중지
docker-compose down

# 서비스 중지 및 볼륨 삭제 (데이터 완전 삭제)
docker-compose down -v

# 이미지 재빌드
docker-compose build --no-cache

# 컨테이너 상태 확인
docker-compose ps

# 헬스체크 상태 확인
docker inspect mongo-db | grep -A 10 Health
```

## 데이터 지속성

- MongoDB 데이터는 `./data/db` 디렉토리에 저장됩니다
- 설정 데이터는 `./data/configdb` 디렉토리에 저장됩니다
- 컨테이너를 삭제해도 데이터는 유지됩니다

## 보안 고려사항

프로덕션 환경에서 사용 시:

1. **강력한 비밀번호 사용**: `MONGO_INITDB_ROOT_PASSWORD`를 복잡하게 설정
2. **환경 변수 관리**: `.env` 파일이나 Docker secrets 사용
3. **네트워크 격리**: 필요한 서비스만 네트워크 공유
4. **SSL/TLS 활성화**: 프로덕션에서는 암호화 연결 사용
5. **방화벽 설정**: 포트를 `127.0.0.1:27017:27017`로 제한
6. **정기 백업**: 자동 백업 스크립트 설정
7. **Mongo Express 비활성화**: 프로덕션에서는 제거 권장

## 문제 해결

### 컨테이너가 시작되지 않는 경우

```bash
# 로그 확인
docker-compose logs mongo-db

# 데이터 디렉토리 권한 확인
ls -la data/

# 포트 충돌 확인
lsof -i :27017
```

### 연결 거부 오류

```bash
# 컨테이너 상태 확인
docker-compose ps

# 네트워크 연결 확인
docker network ls
docker network inspect infra_network
```

### 인증 오류

- 사용자명과 비밀번호가 정확한지 확인
- `authenticationDatabase`를 `admin`으로 지정했는지 확인
- 컨테이너를 재시작해보세요: `docker-compose restart mongo-db`

## 참고 자료

- [MongoDB 공식 문서](https://docs.mongodb.com/)
- [MongoDB Docker Hub](https://hub.docker.com/_/mongo)
- [Mongo Express GitHub](https://github.com/mongo-express/mongo-express)
