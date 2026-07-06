#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MISE_CONFIG="$PROJECT_ROOT/configs/mise/config.toml"

if ! command -v curl > /dev/null 2>&1; then
    echo "curl was not found. Please install it before running the script."
fi
if command -v mise > /dev/null 2>&1; then
    MISE_BIN="$(command -v mise)"
elif [[ -x "${HOME}/.local/bin/mise" ]]; then
    # miseがPATHにないが、インストールされている場合
    MISE_BIN="${HOME}/.local/bin/mise"
else
    curl -fsSL https://mise.run | sh
    MISE_BIN="${HOME}/.local/bin/mise"
fi

export MISE_GLOBAL_CONFIG_FILE="${MISE_CONFIG}"
"${MISE_BIN}" bootstrap --yes --force-dotfiles
