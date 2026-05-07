FROM neo4j:latest

# 한국 시간대 설정
ENV TZ=Asia/Seoul

# 추가 플러그인 설치 (APOC)
ENV NEO4J_PLUGINS=["apoc"]

# 메모리 설정
ENV NEO4J_dbms_memory_heap_initial__size=512m
ENV NEO4J_dbms_memory_heap_max__size=2G
ENV NEO4j_dbms_memory_pagecache_size=1G

# 보안 설정
ENV NEO4J_dbms_security_procedures_unrestricted=apoc.*,algo.*
ENV NEO4J_dbms_security_procedures_allowlist=apoc.*,algo.*

# 디렉토리 권한 설정
USER neo4j

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD cypher-shell -u neo4j -p ${NEO4J_PASSWORD:-test1234} "RETURN 1" || exit 1

EXPOSE 7474 7687
