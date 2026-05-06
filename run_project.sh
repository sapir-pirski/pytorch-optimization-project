#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MIN_PYTHON_MAJOR=3
MIN_PYTHON_MINOR=10
MAX_PYTHON_MAJOR=3
MAX_PYTHON_MINOR=12
PREFERRED_PYTHON_CMD="${PYTHON_CMD:-}"
VENV_DIR="${ROOT_DIR}/.venv"
ENV_FILE="${ROOT_DIR}/env"
INSTALL_STAMP="${VENV_DIR}/.jupyter-installed"
PYTHON_BIN="${VENV_DIR}/bin/python"
PIP_BIN="${VENV_DIR}/bin/pip"
JUPYTER_BIN="${VENV_DIR}/bin/jupyter"
PORT="${PORT:-8888}"

if [ -f "${ENV_FILE}" ]; then
  set -a
  # shellcheck disable=SC1090
  . "${ENV_FILE}"
  set +a
fi

if [ -n "${HF_TOKEN:-}" ] && [ -z "${HUGGING_FACE_HUB_TOKEN:-}" ]; then
  export HUGGING_FACE_HUB_TOKEN="${HF_TOKEN}"
fi

python_version_ok() {
  "$1" -c "import sys; version = sys.version_info[:2]; raise SystemExit(0 if (${MIN_PYTHON_MAJOR}, ${MIN_PYTHON_MINOR}) <= version <= (${MAX_PYTHON_MAJOR}, ${MAX_PYTHON_MINOR}) else 1)"
}

python_version() {
  "$1" -c "import platform; print(platform.python_version())"
}

find_python() {
  local candidate
  for candidate in "${PREFERRED_PYTHON_CMD}" python3.12 python3.11 python3.10 python3 python; do
    if [ -z "${candidate}" ]; then
      continue
    fi

    if command -v "${candidate}" >/dev/null 2>&1 && python_version_ok "${candidate}"; then
      command -v "${candidate}"
      return 0
    fi
  done

  return 1
}

run_as_admin() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    echo "sudo is required to install Python with the detected package manager." >&2
    return 1
  fi
}

install_python() {
  if command -v brew >/dev/null 2>&1; then
    brew install python@3.12 || return 1
    return 0
  fi

  if command -v apt-get >/dev/null 2>&1; then
    run_as_admin apt-get update || return 1
    if run_as_admin apt-get install -y python3.12 python3.12-venv python3.12-pip; then
      return 0
    fi
    run_as_admin apt-get install -y python3 python3-venv python3-pip || return 1
    return 0
  fi

  if command -v dnf >/dev/null 2>&1; then
    if run_as_admin dnf install -y python3.12 python3.12-pip; then
      return 0
    fi
    run_as_admin dnf install -y python3 python3-pip || return 1
    return 0
  fi

  if command -v yum >/dev/null 2>&1; then
    if run_as_admin yum install -y python3.12 python3.12-pip; then
      return 0
    fi
    run_as_admin yum install -y python3 python3-pip || return 1
    return 0
  fi

  if command -v pacman >/dev/null 2>&1; then
    run_as_admin pacman -Sy --noconfirm python || return 1
    return 0
  fi

  if command -v apk >/dev/null 2>&1; then
    run_as_admin apk add python3 py3-pip || return 1
    return 0
  fi

  echo "No supported package manager found. Install Python ${MIN_PYTHON_MAJOR}.${MIN_PYTHON_MINOR}-${MAX_PYTHON_MAJOR}.${MAX_PYTHON_MINOR} manually and rerun this script." >&2
  return 1
}

ensure_python() {
  local resolved_python

  if resolved_python="$(find_python)"; then
    printf '%s\n' "${resolved_python}"
    return 0
  fi

  echo "Python ${MIN_PYTHON_MAJOR}.${MIN_PYTHON_MINOR}-${MAX_PYTHON_MAJOR}.${MAX_PYTHON_MINOR} was not found. Attempting to install Python..." >&2
  if ! install_python; then
    echo "Automatic Python installation failed. Install Python ${MIN_PYTHON_MAJOR}.${MIN_PYTHON_MINOR}-${MAX_PYTHON_MAJOR}.${MAX_PYTHON_MINOR} manually and rerun this script." >&2
    return 1
  fi

  if resolved_python="$(find_python)"; then
    printf '%s\n' "${resolved_python}"
    return 0
  fi

  echo "Python was installed, but Python ${MIN_PYTHON_MAJOR}.${MIN_PYTHON_MINOR}-${MAX_PYTHON_MAJOR}.${MAX_PYTHON_MINOR} is still unavailable on PATH." >&2
  return 1
}

if [ ! -x "${PYTHON_BIN}" ]; then
  SYSTEM_PYTHON="$(ensure_python)"

  echo "Creating virtual environment at ${VENV_DIR} with Python $("${SYSTEM_PYTHON}" -c 'import platform; print(platform.python_version())')..."
  if ! "${SYSTEM_PYTHON}" -m venv "${VENV_DIR}"; then
    echo "Failed to create ${VENV_DIR}. Make sure the Python venv module is installed." >&2
    exit 1
  fi
elif ! python_version_ok "${PYTHON_BIN}"; then
  echo "Existing virtual environment at ${VENV_DIR} uses Python $(python_version "${PYTHON_BIN}")." >&2
  echo "Python ${MIN_PYTHON_MAJOR}.${MIN_PYTHON_MINOR}-${MAX_PYTHON_MAJOR}.${MAX_PYTHON_MINOR} is required. Remove ${VENV_DIR} and rerun this script to recreate it." >&2
  exit 1
fi

if [ ! -f "${INSTALL_STAMP}" ] || [ ! -x "${JUPYTER_BIN}" ]; then
  echo "Installing Jupyter launcher dependencies..."
  "${PIP_BIN}" install --upgrade pip
  "${PIP_BIN}" install jupyterlab==4.5.6 ipykernel==6.31.0
  touch "${INSTALL_STAMP}"
fi

export MPLCONFIGDIR="${ROOT_DIR}/.cache/matplotlib"
export HF_HOME="${ROOT_DIR}/.cache/huggingface"
export JUPYTER_CONFIG_DIR="${ROOT_DIR}/.cache/jupyter/config"
export JUPYTER_RUNTIME_DIR="${ROOT_DIR}/.cache/jupyter/runtime"
export JUPYTER_DATA_DIR="${ROOT_DIR}/.cache/jupyter/data"

mkdir -p \
  "${MPLCONFIGDIR}" \
  "${HF_HOME}" \
  "${JUPYTER_CONFIG_DIR}" \
  "${JUPYTER_RUNTIME_DIR}" \
  "${JUPYTER_DATA_DIR}"

exec "${JUPYTER_BIN}" lab --no-browser --ip=127.0.0.1 --port="${PORT}"
