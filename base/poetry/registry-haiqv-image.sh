#!/usr/bin/env bash
set -euo pipefail

# ================= 설정 =================
REGISTRY="registry.haiqv.ai"
NAMESPACE="haiqv"
IMAGE="poetry-base"
TAG="v1"                      # 필요 시 v1.1 등으로 관리
DOCKERFILE="Dockerfile.base"

# 기본은 L40s(amd64)만 빌드. 멀티아키가 필요하면 실행 시 PLATFORMS를 덮어쓰세요.
# 예) PLATFORMS="linux/amd64,linux/arm64" ./build_base_image.sh
PLATFORMS="${PLATFORMS:-linux/amd64}"

# latest 태그도 함께 발행할지
PUSH_LATEST="${PUSH_LATEST:-true}"

# (옵션) Docker Hub 미러 푸시 여부
PUSH_DOCKERHUB="${PUSH_DOCKERHUB:-false}"
DOCKERHUB_REPO="sigirace/poetry-base"
# =======================================

FULL="${REGISTRY}/${NAMESPACE}/${IMAGE}:${TAG}"
LATEST="${REGISTRY}/${NAMESPACE}/${IMAGE}:latest"

echo "🔨 Building & pushing base image"
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
echo "🔎 Manifest (registry):"
docker buildx imagetools inspect "${FULL}" | sed -n '1,120p'

# (옵션) Docker Hub에도 동일 매니페스트로 미러 푸시
if [ "${PUSH_DOCKERHUB}" = "true" ]; then
  echo
  echo "🌐 Mirroring to Docker Hub: ${DOCKERHUB_REPO}:${TAG}"

  HUB_TAGS=(-t "${DOCKERHUB_REPO}:${TAG}")
  if [ "${PUSH_LATEST}" = "true" ]; then
    HUB_TAGS+=(-t "${DOCKERHUB_REPO}:latest")
  fi

  docker buildx build \
    --pull --no-cache \
    --platform "${PLATFORMS}" \
    -f "${DOCKERFILE}" \
    "${HUB_TAGS[@]}" \
    --push \
    .

  echo
  echo "🔎 Manifest (docker hub):"
  docker buildx imagetools inspect "${DOCKERHUB_REPO}:${TAG}" | sed -n '1,120p'
fi

echo
echo "✅ Done. Pushed: ${FULL}"
if [ "${PUSH_LATEST}" = "true" ]; then
  echo "✅ Also tagged as: ${LATEST}"
fi
