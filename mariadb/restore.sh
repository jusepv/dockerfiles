#!/bin/bash

# MariaDB 복원 스크립트
# 사용법: ./restore.sh <백업파일> [데이터베이스명]

# 기본 설정
CONTAINER_NAME="mariadb-db"
DB_USER="root"
DB_PASSWORD="root1234!"

# 인자 확인
if [ $# -eq 0 ]; then
    echo "❌ 사용법: ./restore.sh <백업파일> [데이터베이스명]"
    echo "예시: ./restore.sh backups/mariadb_20240101_120000.sql.gz"
    echo "예시: ./restore.sh backups/mydb_20240101_120000.sql.gz mydb"
    exit 1
fi

BACKUP_FILE=$1
DB_NAME=${2:-}

# 백업 파일 존재 확인
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ 백업 파일을 찾을 수 없습니다: $BACKUP_FILE"
    exit 1
fi

# 파일 압축 해제 여부 확인
if [[ $BACKUP_FILE == *.gz ]]; then
    echo "📦 압축 파일 해제 중..."
    gunzip -k "$BACKUP_FILE"
    BACKUP_FILE="${BACKUP_FILE%.gz}"
fi

# 복원 시작
if [ -z "$DB_NAME" ]; then
    # 모든 데이터베이스 복원
    echo "⚠️  모든 데이터베이스를 복원합니다. 계속하시겠습니까? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ 복원 취소"
        exit 0
    fi
    
    echo "모든 데이터베이스 복원 시작..."
    docker exec -i $CONTAINER_NAME sh -c "mysql -u$DB_USER -p$DB_PASSWORD" < "$BACKUP_FILE"
else
    # 특정 데이터베이스 복원
    echo "데이터베이스 '$DB_NAME' 복원 시작..."
    docker exec -i $CONTAINER_NAME sh -c "mysql -u$DB_USER -p$DB_PASSWORD $DB_NAME" < "$BACKUP_FILE"
fi

# 복원 완료 확인
if [ $? -eq 0 ]; then
    echo "✅ 복원 완료"
else
    echo "❌ 복원 실패"
    exit 1
fi

# 압축 해제한 임시 파일 삭제
if [[ $1 == *.gz ]]; then
    rm -f "$BACKUP_FILE"
    echo "🗑️  임시 파일 삭제 완료"
fi
