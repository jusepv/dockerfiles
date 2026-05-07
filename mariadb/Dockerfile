FROM mariadb:11.2

# 환경 변수 설정
ENV MYSQL_DATABASE=mariadb
ENV MYSQL_USER=admin
ENV MYSQL_PASSWORD=admin1234!
ENV MYSQL_ROOT_PASSWORD=root1234!

# 한국 시간대 설정
ENV TZ=Asia/Seoul

# 필요한 패키지 설치
RUN apt-get update && \
    apt-get install -y tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# MariaDB 설정 파일 복사 (옵션)
# COPY my.cnf /etc/mysql/conf.d/custom.cnf

# 초기화 스크립트 복사 (옵션)
# COPY init-scripts/ /docker-entrypoint-initdb.d/

# 포트 노출
EXPOSE 3306

# 볼륨 설정
VOLUME ["/var/lib/mysql"]

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD mysqladmin ping -h localhost -u root -p${MYSQL_ROOT_PASSWORD} || exit 1
