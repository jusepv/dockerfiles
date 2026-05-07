#!/usr/bin/env bash
set -euo pipefail

# ================= 설정 =================
REGISTRY="docker.io"
NAMESPACE="sigirace"
IMAGE="poetry-base"
TAG="v1"                      # 필요 시 v1.1 등으로 관리
DOCKERFILE="Dockerfile.base"

# 기본은 L40s(amd64)만 빌드. 멀티아키가 필요하면 실행 시 PLATFORMS를 덮어쓰세요.
# 예) PLATFORMS="linux/amd64,linux/arm64" ./registry-dockerhub-image.sh
PLATFORMS="${PLATFORMS:-linux/amd64}"

# latest 태그도 함께 발행할지
PUSH_LATEST="${PUSH_LATEST:-true}"
# =======================================

FULL="${NAMESPACE}/${IMAGE}:${TAG}"
LATEST="${NAMESPACE}/${IMAGE}:latest"

echo "🔨 Building & pushing Docker Hub image"
echo "  • Image: ${FULL}"
echo "  • File : ${DOCKERFILE}"
echo "  • Arch : ${PLATFORMS}"
echo

# QEMU 등록 (처음 1회면 충분)
docker run --privileged --rm tonistiigi/binfmt --install all >/dev/null 2>&1 || true

# buildx 빌더 준비
BUILDER="multi"
if ! docker buildx inspect "${BUILDER}" >/dev/null 2>&1; then
  docker buildx create --name "${BUILDER}" --use
else
  docker buildx use "${BUILDER}"
fi

# 태그 구성
TAGS=(-t "${FULL}")
if [ "${PUSH_LATEST}" = "true" ]; then
  TAGS+=(-t "${LATEST}")
fi

# 빌드 & 푸시 (로컬에 로드하지 않음)
docker buildx build \
  --pull --no-cache \
  --platform "${PLATFORMS}" \
  -f "${DOCKERFILE}" \
  "${TAGS[@]}" \
  --push \
  .

echo
echo "🔎 Manifest (Docker Hub):"
docker buildx imagetools inspect "${FULL}" | sed -n '1,120p'

echo
echo "✅ Done. Pushed: ${FULL}"
if [ "${PUSH_LATEST}" = "true" ]; then
  echo "✅ Also tagged as: ${LATEST}"
fi