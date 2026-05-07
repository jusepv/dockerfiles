# Milvus Vector Database Docker Setup

이 디렉토리는 Milvus 벡터 데이터베이스를 Docker로 실행하기 위한 구성 파일들을 포함합니다.

## 구성 요소

- **Milvus Standalone**: 벡터 데이터베이스 서버
- **etcd**: 메타데이터 스토리지
- **MinIO**: 객체 스토리지 (벡터 데이터 저장)
- **Attu**: Milvus 관리 웹 UI

## 디렉토리 구조

```
milvus/
├── docker-compose.yml
├── README.md
├── .gitignore
└── data/                    # 데이터 영구 저장 (Git 추적 제외)
    ├── etcd/               # etcd 메타데이터
    ├── minio/              # MinIO 객체 스토리지
    └── milvus/             # Milvus WAL 및 인덱스 데이터
```

## 사용법

### 1. 서비스 시작

```bash
# Milvus 스택 시작
docker-compose up -d

# 로그 확인
docker-compose logs -f milvus-standalone
```

### 2. 서비스 접속 정보

#### Milvus 서버
- **호스트**: localhost
- **포트**: 19530
- **프로토콜**: gRPC

#### MinIO 관리 콘솔
- **URL**: http://localhost:9001
- **사용자명**: minioadmin
- **비밀번호**: minioadmin

#### MinIO S3 API
- **URL**: http://localhost:9000
- **Access Key**: minioadmin
- **Secret Key**: minioadmin

#### Attu (Milvus 웹 UI)
- **URL**: http://localhost:33000
- **Milvus 주소**: milvus-standalone:19530

### 3. Python에서 연결

```python
from pymilvus import connections

# Milvus 연결
connections.connect(
    alias="default",
    host="localhost",
    port="19530"
)
```

### 4. 서비스 관리

```bash
# 서비스 중지
docker-compose down

# 서비스 중지 및 볼륨 삭제 (데이터 완전 삭제)
docker-compose down -v

# 서비스 재시작
docker-compose restart

# 특정 서비스만 재시작
docker-compose restart milvus-standalone
```

## 데이터 지속성

- **etcd 데이터**: `./data/etcd/` 디렉토리에 저장
- **MinIO 데이터**: `./data/minio/` 디렉토리에 저장  
- **Milvus 데이터**: `./data/milvus/` 디렉토리에 저장

컨테이너를 삭제하고 재생성해도 데이터가 유지됩니다.

## 상태 확인

```bash
# 모든 서비스 상태 확인
docker-compose ps

# Milvus 헬스체크
curl -f http://localhost:9091/healthz

# MinIO 헬스체크  
curl -f http://localhost:9000/minio/health/live

# etcd 헬스체크
docker-compose exec milvus-etcd etcdctl endpoint health
```

## 문제 해결

### 컨테이너가 시작되지 않는 경우

```bash
# 로그 확인
docker-compose logs milvus-standalone
docker-compose logs milvus-etcd
docker-compose logs milvus-minio

# 데이터 디렉토리 권한 확인
ls -la data/
```

### "permission denied" 오류 발생 시

```bash
# 데이터 디렉토리 권한 수정
sudo chown -R $(id -u):$(id -g) data/
```

### 포트 충돌 문제

다른 서비스와 포트가 충돌하는 경우 `docker-compose.yml`에서 포트를 변경하세요:

```yaml
ports:
  - "19531:19530"  # Milvus
  - "9002:9000"    # MinIO API
  - "9003:9001"    # MinIO Console
  - "33001:3000"   # Attu
```

## 백업 및 복원

### 백업

```bash
# 서비스 중지
docker-compose down

# 데이터 디렉토리 백업
tar -czf milvus_backup_$(date +%Y%m%d_%H%M%S).tar.gz data/
```

### 복원

```bash
# 서비스 중지
docker-compose down

# 기존 데이터 백업 (선택사항)
mv data/ data_old/

# 백업에서 복원
tar -xzf milvus_backup_YYYYMMDD_HHMMSS.tar.gz

# 서비스 재시작
docker-compose up -d
```

## 성능 튜닝

프로덕션 환경에서는 다음 설정을 고려하세요:

1. **etcd 설정 조정**:
   - `ETCD_QUOTA_BACKEND_BYTES`: 더 큰 값으로 설정
   - `ETCD_AUTO_COMPACTION_RETENTION`: 압축 정책 조정

2. **MinIO 설정**:
   - 더 강력한 액세스 키/시크릿 키 사용
   - 필요시 외부 S3 호환 스토리지 사용

3. **Milvus 설정**:
   - 메모리 및 CPU 리소스 제한 설정
   - 인덱스 빌드 파라미터 튜닝
