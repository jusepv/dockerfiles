# Qdrant Vector Database

벡터 검색을 위한 고성능 벡터 데이터베이스입니다.

## 🚀 빠른 시작

### 서비스 시작

```bash
docker-compose up -d
```

### 서비스 중지

```bash
docker-compose down
```

### 데이터 유지하면서 중지

```bash
docker-compose stop
```

### 로그 확인

```bash
# 실시간 로그
docker-compose logs -f qdrant

# 최근 100줄
docker-compose logs --tail=100 qdrant
```

## 📦 서비스 구성

### Qdrant
- **포트**: 
  - HTTP API: `6333` (웹 UI 포함)
  - gRPC API: `6334`
- **데이터 저장**: `./storage`
- **스냅샷**: `./snapshots`
- **웹 UI**: http://localhost:6333/dashboard

## 🔧 설정

### 환경 변수

주요 환경 변수는 `docker-compose.yml`에서 설정할 수 있습니다:

```yaml
environment:
  QDRANT__LOG_LEVEL: INFO  # debug, info, warn, error
  QDRANT__STORAGE__PERFORMANCE__MAX_SEARCH_THREADS: 4
```

### 커스텀 설정 파일

고급 설정이 필요한 경우 `config/production.yaml` 파일을 생성하고 마운트할 수 있습니다:

```yaml
# config/production.yaml
service:
  host: 0.0.0.0
  http_port: 6333
  grpc_port: 6334

storage:
  storage_path: /qdrant/storage
  snapshots_path: /qdrant/snapshots
  
  # 성능 최적화
  performance:
    max_search_threads: 4
    max_optimization_threads: 2
```

## 🔌 사용 예시

### Python 클라이언트

```python
from qdrant_client import QdrantClient

# 연결
client = QdrantClient(host="localhost", port=6333)

# 컬렉션 생성
client.create_collection(
    collection_name="my_collection",
    vectors_config={"size": 384, "distance": "Cosine"}
)

# 벡터 삽입
client.upsert(
    collection_name="my_collection",
    points=[
        {
            "id": 1,
            "vector": [0.1, 0.2, ...],  # 384 차원
            "payload": {"text": "Hello world"}
        }
    ]
)

# 검색
results = client.search(
    collection_name="my_collection",
    query_vector=[0.1, 0.2, ...],
    limit=10
)
```

### REST API

```bash
# 컬렉션 목록 조회
curl http://localhost:6333/collections

# 컬렉션 생성
curl -X PUT http://localhost:6333/collections/my_collection \
  -H 'Content-Type: application/json' \
  -d '{
    "vectors": {
      "size": 384,
      "distance": "Cosine"
    }
  }'

# 벡터 검색
curl -X POST http://localhost:6333/collections/my_collection/points/search \
  -H 'Content-Type: application/json' \
  -d '{
    "vector": [0.1, 0.2, ...],
    "limit": 10
  }'
```

## 💾 백업 및 복구

### 스냅샷 생성

```bash
# API를 통한 스냅샷 생성
curl -X POST http://localhost:6333/collections/my_collection/snapshots
```

스냅샷 파일은 `./snapshots` 디렉토리에 저장됩니다.

### 복구

```bash
# 스냅샷에서 복구
curl -X PUT http://localhost:6333/collections/my_collection/snapshots/upload \
  -H 'Content-Type: multipart/form-data' \
  -F 'snapshot=@./snapshots/my_collection-snapshot.dat'
```

### 전체 데이터 백업

```bash
# 컨테이너가 실행 중일 때
docker-compose exec qdrant tar czf /qdrant/backup.tar.gz /qdrant/storage

# 호스트로 복사
docker cp qdrant-db:/qdrant/backup.tar.gz ./backup.tar.gz
```

## 🔍 모니터링

### 헬스 체크

```bash
curl http://localhost:6333/healthz
curl http://localhost:6333/readyz
```

### 메트릭 확인

```bash
# Prometheus 형식 메트릭
curl http://localhost:6333/metrics
```

### 컬렉션 정보

```bash
curl http://localhost:6333/collections/my_collection
```

## 🛠️ 유지보수

### 컨테이너 재시작

```bash
docker-compose restart qdrant
```

### 데이터 완전 삭제 및 재시작

```bash
# ⚠️ 주의: 모든 데이터가 삭제됩니다!
docker-compose down -v
rm -rf ./storage ./snapshots
docker-compose up -d
```

### 버전 업그레이드

```bash
docker-compose pull
docker-compose up -d
```

## 📊 성능 최적화

### 인덱스 설정

벡터 검색 성능을 위해 HNSW 파라미터를 조정할 수 있습니다:

```python
client.create_collection(
    collection_name="my_collection",
    vectors_config={"size": 384, "distance": "Cosine"},
    hnsw_config={
        "m": 16,  # 더 높은 값 = 더 나은 검색 품질, 더 많은 메모리
        "ef_construct": 100  # 더 높은 값 = 더 나은 검색 품질, 더 느린 인덱싱
    }
)
```

### 양자화 (Quantization)

메모리 사용량을 줄이려면 벡터 양자화를 활성화할 수 있습니다:

```python
client.update_collection(
    collection_name="my_collection",
    quantization_config={
        "scalar": {
            "type": "int8",
            "quantile": 0.99,
            "always_ram": True
        }
    }
)
```

## 📚 참고 자료

- [Qdrant 공식 문서](https://qdrant.tech/documentation/)
- [Python 클라이언트](https://github.com/qdrant/qdrant-client)
- [REST API 문서](https://qdrant.github.io/qdrant/redoc/index.html)
- [Qdrant Docker Hub](https://hub.docker.com/r/qdrant/qdrant)

## 🔐 보안 고려사항

프로덕션 환경에서는 다음을 권장합니다:

1. **API 키 설정**: `config/production.yaml`에서 API 키 활성화
2. **네트워크 격리**: 필요한 서비스만 접근 가능하도록 네트워크 설정
3. **HTTPS 설정**: 리버스 프록시(Nginx, Traefik)를 통한 HTTPS 연결

```yaml
# config/production.yaml
service:
  api_key: "your-secret-api-key"
```

## 📝 문제 해결

### 컨테이너가 시작되지 않는 경우

```bash
# 로그 확인
docker-compose logs qdrant

# 포트 충돌 확인
lsof -i :6333
lsof -i :6334
```

### 성능 문제

- 메모리 부족: `docker stats`로 메모리 사용량 확인
- 디스크 I/O: SSD 사용 권장
- 스레드 수 조정: `MAX_SEARCH_THREADS` 환경 변수 설정


