FROM redis:7.2-alpine

# supervisor는 /usr/bin/supervisord 로 깔립니다. python3 의존성도 함께 설치.
RUN apk add --no-cache python3 supervisor bash


# 디렉토리
RUN mkdir -p /etc/redis /data /var/log/supervisor

# 설정 복사
COPY redis/redis.conf /etc/redis/redis.conf
COPY redis/sentinel.conf /etc/redis/sentinel.conf
COPY supervisord.conf /etc/supervisord.conf

EXPOSE 6379 26379
VOLUME ["/data"]

# 중요: 절대경로로 supervisord 실행
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
