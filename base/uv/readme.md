## 실행
```
# 권한부여
chmod +x []-image.sh

# 기본 실행 (linux/amd64, v1 태그)
./registry-dockerhub-image.sh

# 멀티 아키텍처로 빌드
PLATFORMS="linux/amd64,linux/arm64" ./registry-dockerhub-image.sh

# latest 태그 없이 빌드
PUSH_LATEST="false" ./registry-dockerhub-image.sh
```

```
chmod +x base/uv/build-base-image.sh base/uv/registry-dockerhub-image.sh base/uv/registry-haiqv-image.sh
```