#!/bin/bash

# MariaDB 백업 스크립트
# 사용법: ./backup.sh [데이터베이스명]

# 기본 설정
CONTAINER_NAME="mariadb-db"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DB_USER="root"
DB_PASSWORD="root1234!"

# 백업 디렉토리 생성
mkdir -p "$BACKUP_DIR"

# 데이터베이스명 인자 확인
if [ $# -eq 0 ]; then
    # 모든 데이터베이스 백업
    BACKUP_FILE="$BACKUP_DIR/mariadb_all_${TIMESTAMP}.sql"
    echo "모든 데이터베이스 백업 시작..."
    docker exec $CONTAINER_NAME sh -c "mysqldump -u$DB_USER -p$DB_PASSWORD --all-databases --single-transaction --quick --lock-tables=false" > "$BACKUP_FILE"
else
    # 특정 데이터베이스 백업
    DB_NAME=$1
    BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql"
    echo "데이터베이스 '$DB_NAME' 백업 시작..."
    docker exec $CONTAINER_NAME sh -c "mysqldump -u$DB_USER -p$DB_PASSWORD --single-transaction --quick --lock-tables=false $DB_NAME" > "$BACKUP_FILE"
fi

# 백업 완료 확인
if [ $? -eq 0 ]; then
    echo "✅ 백업 완료: $BACKUP_FILE"
    
    # 백업 파일 압축
    gzip "$BACKUP_FILE"
    echo "✅ 압축 완료: ${BACKUP_FILE}.gz"
    
    # 백업 파일 크기 확인
    FILESIZE=$(ls -lh "${BACKUP_FILE}.gz" | awk '{print $5}')
    echo "📦 백업 파일 크기: $FILESIZE"
    
    # 30일 이상 된 백업 파일 삭제 (옵션)
    find "$BACKUP_DIR" -name "*.sql.gz" -type f -mtime +30 -delete
    echo "🗑️  30일 이상 된 백업 파일 정리 완료"
else
    echo "❌ 백업 실패"
    exit 1
fi
