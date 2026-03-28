#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

VENV_DIR="${ROOT_DIR}/.venv"
REQUIREMENTS_FILE="${ROOT_DIR}/requirements.txt"
INSTALL_STAMP="${VENV_DIR}/.requirements-installed"
PYTHON_BIN="${VENV_DIR}/bin/python"
PIP_BIN="${VENV_DIR}/bin/pip"
JUPYTER_BIN="${VENV_DIR}/bin/jupyter"

if [ ! -x "${PYTHON_BIN}" ]; then
  if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is required to create ${VENV_DIR}." >&2
    exit 1
  fi

  echo "Creating virtual environment at ${VENV_DIR}..."
  python3 -m venv "${VENV_DIR}"
fi

if [ ! -f "${REQUIREMENTS_FILE}" ]; then
  echo "Missing requirements file: ${REQUIREMENTS_FILE}" >&2
  exit 1
fi

if [ ! -f "${INSTALL_STAMP}" ] || [ "${REQUIREMENTS_FILE}" -nt "${INSTALL_STAMP}" ] || [ ! -x "${JUPYTER_BIN}" ]; then
  echo "Installing Python dependencies from ${REQUIREMENTS_FILE}..."
  "${PIP_BIN}" install --upgrade pip
  "${PIP_BIN}" install -r "${REQUIREMENTS_FILE}"
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

exec "${JUPYTER_BIN}" lab --no-browser --ip=127.0.0.1 --port=8888
