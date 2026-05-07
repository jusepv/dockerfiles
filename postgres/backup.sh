#!/bin/bash

# PostgreSQL 백업 스크립트
# 사용법: ./backup.sh [데이터베이스명]

DB_NAME=${1:-postgres}
BACKUP_DIR="./backups"
CONTAINER_NAME="postgres-db"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_backup_${TIMESTAMP}.sql"

echo "PostgreSQL 백업을 시작합니다..."
echo "데이터베이스: $DB_NAME"
echo "백업 파일: $BACKUP_FILE"

# 백업 실행
docker exec $CONTAINER_NAME pg_dump -U admin -d $DB_NAME > $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "백업이 성공적으로 완료되었습니다!"
    echo "백업 파일: $BACKUP_FILE"
    
    # 압축
    gzip $BACKUP_FILE
    echo "백업 파일이 압축되었습니다: ${BACKUP_FILE}.gz"
else
    echo "백업 중 오류가 발생했습니다."
    exit 1
fi
