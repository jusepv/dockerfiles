# Neo4j Docker 구성

이 폴더는 Neo4j 그래프 데이터베이스를 Docker로 실행하기 위한 구성 파일들을 포함합니다.

## 실행권한

```bash
chmod +x /Users/sigi/kang_dev/dockerfiles/neo4j/backup.sh
chmod +x /Users/sigi/kang_dev/dockerfiles/neo4j/restore.sh
```

## 구성 요소

- `Dockerfile`: Neo4j 최신 버전 기반 커스텀 이미지
- `docker-compose.yml`: Neo4j 서비스 구성
- `backup.sh`: 데이터베이스 백업 스크립트
- `restore.sh`: 데이터베이스 복원 스크립트

## 디렉토리 구조

```
neo4j/
├── docker-compose.yml
├── Dockerfile
├── README.md
├── backup.sh
├── restore.sh
├── data/                 # Neo4j 데이터 파일
├── logs/                 # 로그 파일
├── backups/              # 백업 파일
├── import/               # CSV 등 가져오기 파일
└── plugins/              # 플러그인 (APOC 등)
```

## 빠른 시작

### 1. Docker Compose로 시작

```bash
docker-compose up -d
```

### 2. Docker Run 명령어

```bash
docker run \
  --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/test1234 \
  -v $PWD/data:/data \
  -v $PWD/logs:/logs \
  -d neo4j:latest
```

### 3. 서비스 중지

```bash
docker-compose down
```

### 4. 데이터와 함께 완전 삭제

```bash
docker-compose down -v
```

## 접속 정보

- **웹 브라우저**: http://localhost:7474
- **Bolt 프로토콜**: bolt://localhost:7687
- **사용자명**: neo4j
- **비밀번호**: test1234

## 환경 변수

주요 환경 변수들을 `docker-compose.yml`에서 수정할 수 있습니다:

- `NEO4J_AUTH`: 사용자명/비밀번호 (기본값: neo4j/test1234)
- `NEO4J_dbms_memory_heap_initial__size`: 초기 힙 메모리 (기본값: 512m)
- `NEO4J_dbms_memory_heap_max__size`: 최대 힙 메모리 (기본값: 2G)
- `NEO4j_dbms_memory_pagecache_size`: 페이지 캐시 크기 (기본값: 1G)

## 백업 및 복원

### 백업

```bash
./backup.sh
```

또는

```bash
docker exec neo4j-db neo4j-admin backup --backup-dir=/backups --name=graph.db
```

### 복원

```bash
./restore.sh backup_filename
```

## 플러그인 설치

APOC 플러그인이 기본적으로 설치됩니다. 추가 플러그인을 설치하려면:

1. `plugins/` 디렉토리에 JAR 파일 복사
2. 컨테이너 재시작

```bash
docker-compose restart neo4j
```

## 데이터 가져오기

CSV 파일을 `import/` 디렉토리에 넣고 LOAD CSV 쿼리를 사용:

```cypher
LOAD CSV WITH HEADERS FROM 'file:///data.csv' AS row
CREATE (n:Node {name: row.name})
```

## 트러블슈팅

### 1. 메모리 부족 오류

`docker-compose.yml`에서 메모리 설정을 조정하세요:

```yaml
environment:
  NEO4J_dbms_memory_heap_max__size: 1G
```

### 2. 권한 오류

디렉토리 권한을 확인하세요:

```bash
sudo chown -R 7474:7474 data logs import plugins
```

### 3. 연결 실패

방화벽에서 포트 7474, 7687이 열려있는지 확인하세요.

## 로그 확인

```bash
# 컨테이너 로그
docker-compose logs -f neo4j

# Neo4j 로그 파일
tail -f logs/neo4j.log
```

## 성능 튜닝

프로덕션 환경에서는 다음 설정을 고려하세요:

```yaml
environment:
  NEO4J_dbms_memory_heap_max__size: 4G
  NEO4j_dbms_memory_pagecache_size: 2G
  NEO4J_dbms_tx__log_rotation_retention__policy: 7 days
```

## 보안 설정

프로덕션 환경에서는 강력한 비밀번호를 사용하세요:

```bash
# 비밀번호 변경
docker exec -it neo4j-db cypher-shell -u neo4j -p test1234 "CALL dbms.security.changePassword('new_strong_password')"
```
