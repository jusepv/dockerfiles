# RabbitMQ Docker Compose

이 프로젝트는 Docker Compose를 사용하여 RabbitMQ 메시지 브로커를 쉽게 실행할 수 있도록 구성되었습니다.

## 구성 요소

- **RabbitMQ**: 메시지 브로커 서버
- **Management UI**: 웹 기반 관리 인터페이스

## 기본 설정

- **AMQP 포트**: 5672
- **관리 웹 인터페이스 포트**: 15672
- **기본 사용자**: admin
- **기본 비밀번호**: admin1234!

## 사용 방법

### 1. RabbitMQ 시작

```bash
docker-compose up -d
```

### 2. RabbitMQ 중지

```bash
docker-compose down
```

### 3. 볼륨까지 완전 삭제

```bash
docker-compose down -v
```

### 4. 로그 확인

```bash
docker-compose logs -f rabbitmq
```

## 접속 정보

### 관리 웹 인터페이스

- URL: http://localhost:15672
- 사용자명: admin
- 비밀번호: admin123

### AMQP 연결

- 호스트: localhost
- 포트: 5672
- 사용자명: admin
- 비밀번호: admin123
- Virtual Host: /

## 환경 변수 수정

`.env` 파일을 수정하여 기본 설정을 변경할 수 있습니다:

```env
RABBITMQ_DEFAULT_USER=your_username
RABBITMQ_DEFAULT_PASS=your_password
RABBITMQ_DEFAULT_VHOST=/your_vhost
```

## 볼륨

다음 볼륨이 데이터 영속성을 위해 생성됩니다:

- `rabbitmq_data`: RabbitMQ 데이터
- `rabbitmq_logs`: RabbitMQ 로그

## 네트워크

`rabbitmq_net` 브리지 네트워크가 생성되어 컨테이너 간 통신을 지원합니다.

## 상태 확인

컨테이너 상태를 확인하려면:

```bash
docker-compose ps
```

RabbitMQ 상태를 확인하려면:

```bash
docker-compose exec rabbitmq rabbitmq-diagnostics status
```
