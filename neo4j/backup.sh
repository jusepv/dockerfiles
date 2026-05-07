#!/bin/bash

# Neo4j 백업 스크립트
# 사용법: ./backup.sh [백업명]

set -e

# 설정
CONTAINER_NAME="neo4j-db"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME=${1:-"neo4j_backup_${TIMESTAMP}"}

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Neo4j 백업을 시작합니다...${NC}"

# 백업 디렉토리 생성
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${YELLOW}백업 디렉토리를 생성합니다: $BACKUP_DIR${NC}"
    mkdir -p "$BACKUP_DIR"
fi

# 컨테이너 상태 확인
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}오류: $CONTAINER_NAME 컨테이너가 실행 중이 아닙니다.${NC}"
    echo "다음 명령어로 컨테이너를 시작하세요:"
    echo "docker-compose up -d"
    exit 1
fi

echo -e "${YELLOW}백업 중... 잠시만 기다리세요.${NC}"

# Neo4j 백업 실행
docker exec "$CONTAINER_NAME" neo4j-admin database backup neo4j --to-path=/backups

# 백업 파일을 호스트로 복사
docker cp "$CONTAINER_NAME:/backups/neo4j" "$BACKUP_DIR/$BACKUP_NAME"

# 백업 압축
echo -e "${YELLOW}백업을 압축하는 중...${NC}"
cd "$BACKUP_DIR"
tar -czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"
rm -rf "$BACKUP_NAME"

# 백업 크기 확인
BACKUP_SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)

echo -e "${GREEN}✅ 백업이 완료되었습니다!${NC}"
echo -e "${GREEN}백업 파일: $BACKUP_DIR/${BACKUP_NAME}.tar.gz${NC}"
echo -e "${GREEN}파일 크기: $BACKUP_SIZE${NC}"

# 오래된 백업 파일 정리 (7일 이상 된 파일)
echo -e "${YELLOW}오래된 백업 파일을 정리합니다 (7일 이상)...${NC}"
find "$BACKUP_DIR" -name "neo4j_backup_*.tar.gz" -mtime +7 -delete 2>/dev/null || true

echo -e "${BLUE}백업 스크립트가 완료되었습니다.${NC}"

# 백업 목록 표시
echo -e "\n${BLUE}현재 백업 파일 목록:${NC}"
ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null || echo "백업 파일이 없습니다."
