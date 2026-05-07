# Redis 공식 이미지를 기반으로 사용
FROM redis:7.2-alpine

# Redis 설정 파일 복사
COPY redis.conf /usr/local/etc/redis/redis.conf

# Redis 설정 파일 권한 설정
RUN chown redis:redis /usr/local/etc/redis/redis.conf

# 작업 디렉토리 설정
WORKDIR /data

# Redis 포트 노출
EXPOSE 6379

# Redis 데이터 볼륨 설정
VOLUME ["/data"]

# Redis 사용자로 실행
USER redis

# Redis 서버 시작 명령어 (설정 파일과 함께)
CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
