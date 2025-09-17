#!/usr/bin/env bash
set -euo pipefail

HOST_UID="${HOST_UID:-1000}"
HOST_GID="${HOST_GID:-1000}"
HOST_USER="${HOST_USER:-user}"

group_name="hostgroup"
user_name="${HOST_USER}"

if ! getent group "${group_name}" >/dev/null 2>&1; then
  groupadd -g "${HOST_GID}" "${group_name}" >/dev/null 2>&1 || true
fi

if ! id -u "${user_name}" >/dev/null 2>&1; then
  useradd -m -u "${HOST_UID}" -g "${HOST_GID}" -s /bin/bash "${user_name}" >/dev/null 2>&1 || true
fi

usermod -aG sudo "${user_name}" >/dev/null 2>&1 || true

export HOME="/home/${user_name}"
mkdir -p "${HOME}"
chown -R "${HOST_UID}:${HOST_GID}" "${HOME}" || true

echo "Running as ${user_name} (uid=${HOST_UID}, gid=${HOST_GID})"

exec gosu "${user_name}" "$@"


