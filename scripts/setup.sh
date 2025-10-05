#!/bin/bash
set -eux
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

function install_mise() {
    curl https://mise.run | sh
    eval "$(~/.local/bin/mise activate bash)"
}

function create_symlink() {
    local target=$1
    local path=$2
    ln -sfn "$target" "$path"
}

function remove_dotprofile() {
    local key=$1
    removeRC "$key" ~/.profile
}

function remove_bashrc() {
    local key=$1
    removeRC "$key" ~/.bashrc
}

function add_dotprofile() {
    local key=$1
    local val=$2
    addRC "$key" "$val" ~/.profile
}

function add_bashrc() {
    local key=$1
    local val=$2
    addRC "$key" "$val" ~/.bashrc
}

function addRC() {
    local key=$1
    local val=$2
    local file=$3
    if ! grep -q "$key" "$file"; then
        echo "#$key" >> "$file"
        echo "$val" >> "$file"
    fi
}

function removeRC() {
    local key=$1
    local file=$2
    sed -i "/^#${key}$/,+1d" "$file"
}

mkdir -p "$HOME/.config"
create_symlink "${PROJECT_ROOT}/configs/mise" "$HOME/.config/mise"
create_symlink "${PROJECT_ROOT}/configs/nvim" "$HOME/.config/nvim"
create_symlink "${PROJECT_ROOT}/configs/wezterm" "$HOME/.config/wezterm"
create_symlink "${PROJECT_ROOT}/configs/alacritty" "$HOME/.config/alacritty"
create_symlink "${PROJECT_ROOT}/configs/starship" "$HOME/.config/starship"
mkdir -p "$HOME/.codex"
create_symlink "${PROJECT_ROOT}/configs/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
create_symlink "${PROJECT_ROOT}/configs/tmux/.tmux.conf" "$HOME/.tmux.conf"

install_mise
$HOME/.local/bin/mise -C "$HOME" install
remove_dotprofile "STARSHIP"
remove_dotprofile "MISE_CONFIG"
add_dotprofile "ENV_STARSHIP_CONFIG" "export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml"
add_dotprofile "MISE_CONFIG" 'eval "$(~/.local/bin/mise activate bash)"'
remove_bashrc "STARSHIP"
add_bashrc "STARSHIP" 'eval "$(starship init bash)"'
