#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# Start JupyterLab as the unprivileged jovyan user (UID 1000, GID 100).

set -euo pipefail

JUPYTER_BIN="/opt/jupyter/.pixi/envs/default/bin/jupyter"
JUPYTER_ARGS=(
  lab
  --ip=0.0.0.0
  --port=8888
  --no-browser
  --ServerApp.token=
  --ServerApp.password=
  --ServerApp.allow_remote_access=True
  --ServerApp.root_dir=/home/jovyan
  --MappingKernelManager.default_kernel_name=python-pixi
)

if [[ "$(id -u)" -eq 0 ]]; then
  mkdir -p /home/jovyan
  chown jovyan:users /home/jovyan 2>/dev/null || true
  mkdir -p /home/jovyan/.local /home/jovyan/.cache
  chown -R jovyan:users /home/jovyan/.local /home/jovyan/.cache 2>/dev/null || true

  exec setpriv --reuid=1000 --regid=100 --init-groups \
    env HOME=/home/jovyan \
        SHELL=/usr/bin/zsh \
        JUPYTER_PATH=/usr/local/share/jupyter \
        "$JUPYTER_BIN" "${JUPYTER_ARGS[@]}"
fi

exec env HOME=/home/jovyan \
    SHELL=/usr/bin/zsh \
    JUPYTER_PATH=/usr/local/share/jupyter \
    "$JUPYTER_BIN" "${JUPYTER_ARGS[@]}"
