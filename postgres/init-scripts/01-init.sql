-- 초기화 스크립트 예시
-- 이 파일은 PostgreSQL 컨테이너가 처음 시작될 때 자동으로 실행됩니다.

-- 예시: 새 데이터베이스 생성
-- CREATE DATABASE myapp;

-- 예시: 새 사용자 생성
-- CREATE USER myapp_user WITH ENCRYPTED PASSWORD 'myapp_password';
-- GRANT ALL PRIVILEGES ON DATABASE myapp TO myapp_user;

-- 예시: 샘플 테이블 생성
-- \c myapp;
-- CREATE TABLE users (
--     id SERIAL PRIMARY KEY,
--     username VARCHAR(50) UNIQUE NOT NULL,
--     email VARCHAR(100) UNIQUE NOT NULL,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- 초기 데이터 삽입 예시
-- INSERT INTO users (username, email) VALUES 
-- ('admin', 'admin@example.com'),
-- ('user1', 'user1@example.com');

-- 기본 설정 확인
SELECT version();
SELECT current_database();
SELECT current_user;
