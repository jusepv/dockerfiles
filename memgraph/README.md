# Memgraph Docker 구성

이 폴더는 Memgraph 그래프 데이터베이스를 Docker로 실행하기 위한 구성 파일들을 포함합니다.

## 구성 요소

- `docker-compose.yaml`: Memgraph와 Memgraph Lab 서비스 구성

## 디렉토리 구조

```
memgraph/
├── docker-compose.yaml
└── README.md
```

## 서비스 설명

| 서비스 | 이미지 | 설명 |
|--------|--------|------|
| memgraph | memgraph/memgraph-mage | MAGE (Memgraph Advanced Graph Extensions) 포함 그래프 DB |
| memgraph-lab | memgraph/lab | 웹 기반 관리 UI |

## 사용법

### 1. 서비스 시작

```bash
# 서비스 빌드 및 시작
docker-compose up -d

# 로그 확인
docker-compose logs -f memgraph
```

### 2. 데이터베이스 접속

#### Memgraph Lab (웹 UI)

- URL: http://localhost:7688
- Quick Connect로 바로 연결 가능 (memgraph 호스트 자동 설정)

#### 명령줄에서 접속

```bash
# 컨테이너 내부에서 mgconsole로 접속
docker exec -it memgraph-db mgconsole

# Cypher 쿼리 실행 예시
docker exec -it memgraph-db mgconsole --execute "MATCH (n) RETURN n LIMIT 10;"
```

#### Bolt 프로토콜로 접속 (애플리케이션)

```python
# Python 예시 (neo4j 드라이버 사용)
from neo4j import GraphDatabase

# 기본 설정 (인증 없음)
driver = GraphDatabase.driver("bolt://localhost:7687")

# 인증 활성화 시
# driver = GraphDatabase.driver(
#     "bolt://localhost:7687",
#     auth=("username", "password")
# )
```

### 3. 서비스 관리

```bash
# 서비스 중지
docker-compose down

# 서비스 중지 및 볼륨 삭제 (데이터 완전 삭제)
docker-compose down -v

# 서비스 재시작
docker-compose restart

# 상태 확인
docker-compose ps
```

## 연결 정보

| 항목 | 값 |
|------|-----|
| Bolt 호스트 | localhost |
| Bolt 포트 | 7687 |
| Lab 포트 | 7688 (-> 3000) |
| 인증 | 기본 비활성화 |

## 포트 설명

| 포트 | 설명 |
|------|------|
| 7687 | Bolt 프로토콜 (클라이언트 연결) |
| 7444 | 웹소켓/HTTP |
| 7688 | Memgraph Lab 웹 UI |

## Cypher 쿼리 예시

```cypher
-- 노드 생성
CREATE (n:Person {name: 'Alice', age: 30});

-- 관계 생성
MATCH (a:Person {name: 'Alice'}), (b:Person {name: 'Bob'})
CREATE (a)-[:KNOWS]->(b);

-- 모든 노드 조회
MATCH (n) RETURN n;

-- 관계 조회
MATCH (a)-[r]->(b) RETURN a, r, b;

-- 노드 삭제
MATCH (n:Person {name: 'Alice'}) DETACH DELETE n;
```

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
docker-compose logs memgraph

# 헬스체크 상태 확인
docker inspect memgraph-db | grep Health -A 10
```

### 메모리 부족 오류

`docker-compose.yaml`에서 `--memory-limit` 값을 조정하세요:

```yaml
command: >
  --memory-limit=2048  # MB 단위
```

### 연결 거부 오류

```bash
# 컨테이너 상태 확인
docker-compose ps

# Bolt 포트 확인
docker exec -it memgraph-db netstat -tlnp | grep 7687
```

## 참고 자료

- [Memgraph 공식 문서](https://memgraph.com/docs)
- [Memgraph MAGE](https://memgraph.com/docs/mage)
- [Cypher 쿼리 언어](https://memgraph.com/docs/cypher-manual)
