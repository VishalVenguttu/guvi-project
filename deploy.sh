#!/bin/bash
set -euo pipefail

# ==== Config ====
DOCKERHUB_USER="vishalsezhiyan"   # <-- change this
BRANCH="${1:-dev}"
BUILD_NUMBER="${2:-latest}"
CONTAINER_NAME="devops-build-app"
HOST_PORT="8081"
CONTAINER_PORT="80"

if [ "$BRANCH" == "master" ]; then
    REPO_NAME="${DOCKERHUB_USER}/prod"
else
    REPO_NAME="${DOCKERHUB_USER}/dev"
fi

IMAGE_TAG="${REPO_NAME}:${BUILD_NUMBER}"

echo "==================================="
echo " Deploying ${IMAGE_TAG}"
echo "==================================="

# ==== Push to Docker Hub ====
echo "Pushing image to Docker Hub..."
sudo docker push "${IMAGE_TAG}"
sudo docker push "${REPO_NAME}:latest"

# ==== Stop and remove old container ====
if sudo docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
    echo "Stopping existing container: ${CONTAINER_NAME}"
    sudo docker stop "${CONTAINER_NAME}" || true
    sudo docker rm "${CONTAINER_NAME}" || true
fi

# ==== Run new container ====
echo "Starting new container: ${CONTAINER_NAME}"
sudo docker run -d \
    --name "${CONTAINER_NAME}" \
    -p "${HOST_PORT}:${CONTAINER_PORT}" \
    --restart unless-stopped \
    "${IMAGE_TAG}"

sleep 2
sudo docker ps --filter "name=${CONTAINER_NAME}"

if curl -sf -o /dev/null "http://localhost:${HOST_PORT}"; then
    echo "Deployment successful: ${IMAGE_TAG} live on port ${HOST_PORT}"
else
    echo "WARNING: App not responding. Check logs:"
    echo "  sudo docker logs ${CONTAINER_NAME}"
fi
