#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-tt-metal-dev:latest}"
CONTAINER_NAME="${CONTAINER_NAME:-tt-metal-dev}"

# Absolute host workspace path
WORKSPACE_HOST="/home/kilka/Projects/ML/TT-NN/dev.docker/workspace"

mkdir -p "${WORKSPACE_HOST}"

# Build image if not present or if BUILD=1 is set
if ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1 || [[ "${BUILD:-0}" == "1" ]]; then
  docker build -t "${IMAGE_NAME}" -f \
    "/home/kilka/Projects/ML/TT-NN/dev.docker/Dockerfile" \
    "/home/kilka/Projects/ML/TT-NN/dev.docker"
fi

# Default command: bash (pass through any user command)
if [[ $# -gt 0 ]]; then
  CMD=("$@")
else
  CMD=("bash")
fi

exec docker run --rm -it \
  --name "${CONTAINER_NAME}" \
  -v "${WORKSPACE_HOST}:/workspace" \
  -w /workspace \
  -u "$(id -u):$(id -g)" \
  "${IMAGE_NAME}" \
  "${CMD[@]}"


