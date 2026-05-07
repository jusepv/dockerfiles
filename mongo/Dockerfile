# MongoDB 공식 이미지를 기반으로 사용
FROM mongo:6.0

# mongo-keyfile 복사 (Replica Set 인증용)
COPY mongo-keyfile /etc/mongo-keyfile
RUN chmod 600 /etc/mongo-keyfile && chown mongodb:mongodb /etc/mongo-keyfile
