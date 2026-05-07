#!/bin/bash

# PostgreSQL 복원 스크립트
# 사용법: ./restore.sh <백업파일명> [데이터베이스명]

if [ -z "$1" ]; then
    echo "사용법: $0 <백업파일명> [데이터베이스명]"
    echo "예시: $0 postgres_backup_20231207_143022.sql.gz postgres"
    exit 1
fi

BACKUP_FILE="./backups/$1"
DB_NAME=${2:-postgres}
CONTAINER_NAME="postgres-db"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "백업 파일을 찾을 수 없습니다: $BACKUP_FILE"
    exit 1
fi

echo "PostgreSQL 복원을 시작합니다..."
echo "백업 파일: $BACKUP_FILE"
echo "데이터베이스: $DB_NAME"

# 압축 파일인지 확인
if [[ $BACKUP_FILE == *.gz ]]; then
    echo "압축된 백업 파일을 복원합니다..."
    gunzip -c $BACKUP_FILE | docker exec -i $CONTAINER_NAME psql -U admin -d $DB_NAME
else
    echo "백업 파일을 복원합니다..."
    docker exec -i $CONTAINER_NAME psql -U admin -d $DB_NAME < $BACKUP_FILE
fi

if [ $? -eq 0 ]; then
    echo "복원이 성공적으로 완료되었습니다!"
else
    echo "복원 중 오류가 발생했습니다."
    exit 1
fi
