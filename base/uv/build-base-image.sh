#!/bin/bash

# Docker 베이스 이미지 빌드 스크립트

# 변수 설정
BASE_IMAGE_NAME="sigirace/uv-base"
BASE_IMAGE_TAG="latest"
FULL_BASE_IMAGE_NAME="${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"

echo "🔨 Building Docker base image: ${FULL_BASE_IMAGE_NAME}"

# 베이스 이미지 빌드
docker build \
    -f Dockerfile.base \
    -t ${FULL_BASE_IMAGE_NAME} \
    -t ${BASE_IMAGE_NAME}:latest \
    --platform linux/amd64 \
    .

if [ $? -eq 0 ]; then
    echo "✅ Base image built successfully: ${FULL_BASE_IMAGE_NAME}"
    
    # 이미지 정보 출력
    echo "📋 Image information:"
    docker image inspect ${FULL_BASE_IMAGE_NAME} --format='{{json .Config.Labels}}' | jq .
    
    echo "📏 Image size:"
    docker images ${BASE_IMAGE_NAME} --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    
    # 푸시 여부 확인
    read -p "🚀 Do you want to push this image to Docker Hub? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🚀 Pushing ${FULL_BASE_IMAGE_NAME} to Docker Hub..."
        docker push ${FULL_BASE_IMAGE_NAME}
        docker push ${BASE_IMAGE_NAME}:latest
        echo "✅ Image pushed successfully!"
    fi
else
    echo "❌ Failed to build base image"
    exit 1
fi
