#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-tt-metal-dev:latest}"
CONTAINER_NAME="${CONTAINER_NAME:-tt-metal-dev}"
RECREATE="${RECREATE:-0}"
REBUILD="${REBUILD:-0}"

# Absolute host workspace path
WORKSPACE_HOST="/home/kilka/Projects/ML/TT-NN/dev.docker/workspace"

mkdir -p "${WORKSPACE_HOST}"

# Ensure symlinks in workspace for external repos if missing
ensure_symlink() {
  local link_path="$1"
  local src_path="$2"
  local name="$3"

  if [[ -e "${link_path}" || -L "${link_path}" ]]; then
    echo "[info] ${name}: уже существует в workspace: ${link_path}"
    return 0
  fi

  if [[ -n "${src_path}" && -d "${src_path}" ]]; then
    ln -s "${src_path}" "${link_path}"
    echo "[ok] ${name}: создан symlink ${link_path} -> ${src_path}"
  else
    echo "[warn] ${name}: исходный путь не найден. Установите переменную окружения и повторите."
  fi
}

# Allow both PYTORCH_TTNN_SRC and PYTORCH2_TTNN_SRC names
PYTORCH_TTNN_SRC="${PYTORCH_TTNN_SRC:-${PYTORCH2_TTNN_SRC:-}}"
TT_METAL_SRC="${TT_METAL_SRC:-}"

ensure_symlink "${WORKSPACE_HOST}/pytorch2.0_ttnn" "${PYTORCH_TTNN_SRC}" "pytorch2.0_ttnn (env: PYTORCH_TTNN_SRC or PYTORCH2_TTNN_SRC)"
ensure_symlink "${WORKSPACE_HOST}/tt-metal" "${TT_METAL_SRC}" "tt-metal (env: TT_METAL_SRC)"


# Parse optional script flags (e.g., --recreate), then pass the rest as container command
while [[ $# -gt 0 ]]; do
  case "$1" in
    --recreate)
      RECREATE=1
      shift
      ;;
    --rebuild)
      REBUILD=1
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

# Remaining args form the command to run inside the container
if [[ $# -gt 0 ]]; then
  CMD=("$@")
else
  CMD=("bash")
fi

# Build image if not present or if BUILD=1/--rebuild is set (after parsing flags)
if ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1 || [[ "${BUILD:-0}" == "1" || "${REBUILD}" == "1" ]]; then
  echo "[info] Собираю образ: ${IMAGE_NAME}"
  docker build -t "${IMAGE_NAME}" -f \
    "/home/kilka/Projects/ML/TT-NN/dev.docker/Dockerfile" \
    "/home/kilka/Projects/ML/TT-NN/dev.docker"
  echo "[ok] Образ собран: ${IMAGE_NAME}"
fi

# Recreate container if requested and it exists
if [[ "${RECREATE}" == "1" ]]; then
  if docker ps -a --format '{{.Names}}' | grep -qx "${CONTAINER_NAME}"; then
    if docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1; then
      echo "[ok] Удалён существующий контейнер: ${CONTAINER_NAME}"
    else
      echo "[warn] Не удалось удалить контейнер: ${CONTAINER_NAME}"
    fi
  else
    echo "[info] Контейнер не найден, удалять нечего: ${CONTAINER_NAME}"
  fi
fi

exec docker run --rm -it \
  --name "${CONTAINER_NAME}" \
  -v "${WORKSPACE_HOST}:/workspace" \
  -w /workspace \
  -e HOST_UID="$(id -u)" \
  -e HOST_GID="$(id -g)" \
  -e HOST_USER="${USER:-user}" \
  "${IMAGE_NAME}" \
  "${CMD[@]}"


