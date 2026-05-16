#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/train"
STATE_DIR="${HOME}/.local/share/train"

mkdir -p "${BIN_DIR}" "${CONFIG_DIR}" "${STATE_DIR}"

install -m 755 "${ROOT}/train" "${BIN_DIR}/train"

if [[ ! -f "${CONFIG_DIR}/config.json" ]]; then
  install -m 644 "${ROOT}/config.example.json" "${CONFIG_DIR}/config.json"
  echo "Installed config -> ${CONFIG_DIR}/config.json"
else
  echo "Config exists, skipped: ${CONFIG_DIR}/config.json"
fi

echo "Installed train -> ${BIN_DIR}/train"
echo
if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "Config: ~/Library/Application Support/train/config.json"
  echo "Add to ~/.zshrc:"
  echo '  [[ $SHLVL -eq 1 && -t 0 ]] && train'
else
  echo "Config: ~/.config/train/config.json"
  echo "Add to ~/.zshrc:"
  echo '  [[ $SHLVL -eq 1 && -t 0 ]] && train'
fi
