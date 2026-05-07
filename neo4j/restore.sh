#!/bin/bash

# Neo4j 복원 스크립트
# 사용법: ./restore.sh <백업파일명>

set -e

# 설정
CONTAINER_NAME="neo4j-db"
BACKUP_DIR="./backups"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 인수 확인
if [ $# -eq 0 ]; then
    echo -e "${RED}오류: 백업 파일명을 지정해주세요.${NC}"
    echo "사용법: $0 <백업파일명>"
    echo ""
    echo "사용 가능한 백업 파일:"
    ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | sed 's/.*\///' || echo "백업 파일이 없습니다."
    exit 1
fi

BACKUP_FILE="$1"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILE"

# 백업 파일 확인
if [ ! -f "$BACKUP_PATH" ]; then
    echo -e "${RED}오류: 백업 파일을 찾을 수 없습니다: $BACKUP_PATH${NC}"
    echo ""
    echo "사용 가능한 백업 파일:"
    ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | sed 's/.*\///' || echo "백업 파일이 없습니다."
    exit 1
fi

echo -e "${BLUE}Neo4j 복원을 시작합니다...${NC}"
echo -e "${YELLOW}백업 파일: $BACKUP_PATH${NC}"

# 확인 메시지
echo -e "${YELLOW}⚠️  경고: 현재 데이터베이스의 모든 데이터가 삭제됩니다!${NC}"
read -p "계속하시겠습니까? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}복원이 취소되었습니다.${NC}"
    exit 0
fi

# 컨테이너 중지
echo -e "${YELLOW}Neo4j 컨테이너를 중지합니다...${NC}"
docker-compose stop neo4j 2>/dev/null || docker stop "$CONTAINER_NAME" 2>/dev/null || true

# 기존 데이터 백업 (안전을 위해)
CURRENT_BACKUP="./data_backup_$(date +"%Y%m%d_%H%M%S")"
if [ -d "./data" ]; then
    echo -e "${YELLOW}기존 데이터를 백업합니다: $CURRENT_BACKUP${NC}"
    cp -r "./data" "$CURRENT_BACKUP"
fi

# 기존 데이터 삭제
echo -e "${YELLOW}기존 데이터를 삭제합니다...${NC}"
rm -rf "./data"/*

# 백업 파일 압축 해제
echo -e "${YELLOW}백업 파일을 압축 해제합니다...${NC}"
TEMP_DIR=$(mktemp -d)
tar -xzf "$BACKUP_PATH" -C "$TEMP_DIR"

# 백업된 데이터를 data 디렉토리로 복사
BACKUP_NAME=$(basename "$BACKUP_FILE" .tar.gz)
cp -r "$TEMP_DIR/$BACKUP_NAME"/* "./data/"

# 임시 디렉토리 정리
rm -rf "$TEMP_DIR"

# 권한 설정
echo -e "${YELLOW}권한을 설정합니다...${NC}"
sudo chown -R 7474:7474 "./data" 2>/dev/null || chown -R 7474:7474 "./data" 2>/dev/null || true

# 컨테이너 시작
echo -e "${YELLOW}Neo4j 컨테이너를 시작합니다...${NC}"
docker-compose up -d neo4j

# 시작 대기
echo -e "${YELLOW}Neo4j가 시작될 때까지 대기합니다...${NC}"
sleep 10

# 연결 테스트
MAX_ATTEMPTS=30
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if docker exec "$CONTAINER_NAME" cypher-shell -u neo4j -p test1234 "RETURN 1" &>/dev/null; then
        echo -e "${GREEN}✅ Neo4j가 성공적으로 시작되었습니다!${NC}"
        break
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
    echo -e "${YELLOW}Neo4j 시작 대기 중... ($ATTEMPT/$MAX_ATTEMPTS)${NC}"
    sleep 2
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo -e "${RED}오류: Neo4j 시작 시간이 초과되었습니다.${NC}"
    echo "로그를 확인해보세요:"
    echo "docker-compose logs neo4j"
    exit 1
fi

echo -e "${GREEN}✅ 복원이 완료되었습니다!${NC}"
echo -e "${GREEN}웹 브라우저에서 http://localhost:7474 로 접속할 수 있습니다.${NC}"
echo -e "${GREEN}사용자명: neo4j, 비밀번호: test1234${NC}"

# 기존 데이터 백업 정리 안내
if [ -d "$CURRENT_BACKUP" ]; then
    echo ""
    echo -e "${BLUE}기존 데이터가 다음 위치에 백업되었습니다: $CURRENT_BACKUP${NC}"
    echo -e "${BLUE}필요 없다면 다음 명령어로 삭제할 수 있습니다:${NC}"
    echo "rm -rf $CURRENT_BACKUP"
fi
