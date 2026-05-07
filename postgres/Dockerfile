FROM postgres:16-alpine

# 환경 변수 설정
ENV POSTGRES_DB=postgres
ENV POSTGRES_USER=admin
ENV POSTGRES_PASSWORD=admin1234!

# 한국 시간대 설정
ENV TZ=Asia/Seoul

# 필요한 패키지 설치
RUN apk add --no-cache tzdata

# PostgreSQL 설정 파일 복사 (옵션)
# COPY postgresql.conf /etc/postgresql/postgresql.conf
# COPY pg_hba.conf /etc/postgresql/pg_hba.conf

# 초기화 스크립트 복사 (옵션)
# COPY init-scripts/ /docker-entrypoint-initdb.d/

# 포트 노출
EXPOSE 5432

# 볼륨 설정
VOLUME ["/var/lib/postgresql/data"]

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD pg_isready -U admin -d postgres || exit 1
