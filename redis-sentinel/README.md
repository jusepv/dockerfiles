### 빌드 실행

```
# 빌드
docker-compose up -d
```

### 동작 확인

```
# Redis (6379)
redis-cli -p 6379 ping
# => PONG

# Sentinel (26379)
redis-cli -p 26379 -a 'admin1234!' SENTINEL get-master-addr-by-name mymaster
# => 1) "127.0.0.1"
#    2) "6379"
```
