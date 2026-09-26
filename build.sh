#!/bin/bash
set -euo pipefail

# ==== Config ====
DOCKERHUB_USER="vishalsezhiyan"   
BRANCH="${1:-dev}"                        # dev or master, passed by Jenkins
BUILD_NUMBER="${2:-latest}"               # Jenkins BUILD_NUMBER or 'latest'

# Choose repo based on branch
if [ "$BRANCH" == "master" ]; then
    REPO_NAME="${DOCKERHUB_USER}/prod"
else
    REPO_NAME="${DOCKERHUB_USER}/dev"
fi

IMAGE_TAG="${REPO_NAME}:${BUILD_NUMBER}"
IMAGE_LATEST="${REPO_NAME}:latest"

echo "==================================="
echo " Branch      : ${BRANCH}"
echo " Building    : ${IMAGE_TAG}"
echo "==================================="

sudo docker build -t "${IMAGE_TAG}" -t "${IMAGE_LATEST}" .

echo "-----------------------------------"
echo " Build complete: ${IMAGE_TAG}"
docker images "${REPO_NAME}"
echo "-----------------------------------"
