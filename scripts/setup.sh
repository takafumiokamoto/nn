#!/bin/bash
set -eux
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

function create_symlink() {
    local target=$1
    local path=$2
    ln -sfn "$target" "$path"
}

function add_dotprofile() {
    local key=$1
    local val=$2
    if ! grep -q "$key" ~/.profile; then
        echo "#$key" >> ~/.profile
        echo "$val" >> ~/.profile
    fi
}

function install_neovim() {
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
    chmod u+x nvim-linux-x86_64.appimage
    mkdir -p "$HOME/bin/nvim"
    mv nvim-linux-x86_64.appimage "$HOME/bin/nvim/nvim"
    add_dotprofile "ENV_NVIM_PATH" 'export PATH="$HOME/bin/nvim/:$PATH"'
}

# install aqua
curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v4.0.2/aqua-installer
echo "98b883756cdd0a6807a8c7623404bfc3bc169275ad9064dc23a6e24ad398f43d  aqua-installer" | sha256sum -c -
chmod +x aqua-installer
./aqua-installer
rm aqua-installer

# set path
add_dotprofile "ENV_AQUA_BIN" 'export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"'
add_dotprofile "ENV_AQUA_GLOBAL_CONFIG" "export AQUA_GLOBAL_CONFIG=${PROJECT_ROOT}/aqua.yaml"
add_dotprofile "ENV_AQUA_PROGRESS_BAR" "export AQUA_PROGRESS_BAR=true"
source "$HOME/.profile"
aqua install -l -a
aqua install -a --tags essential

if ! command -v cmake &> /dev/null; then
    sudo apt update
    sudo apt install -y cmake
fi

# install neovim
install_neovim

mkdir -p "$HOME/.config"

create_symlink "${PROJECT_ROOT}/configs/nvim" "$HOME/.config/nvim"
create_symlink "${PROJECT_ROOT}/configs/claude" "$HOME/.config/claude"
create_symlink "${PROJECT_ROOT}/configs/wezterm" "$HOME/.config/wezterm"
create_symlink "${PROJECT_ROOT}/configs/alacritty" "$HOME/.config/alacritty"
mkdir -p "$HOME/.config/Code"
create_symlink "${PROJECT_ROOT}/configs/vscode" "$HOME/.config/Code/User"
create_symlink "${PROJECT_ROOT}/configs/starship" "$HOME/.config/starship"
add_dotprofile "ENV_STARSHIP_CONFIG" "export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml"
create_symlink "${PROJECT_ROOT}/configs/codex/config.toml" "$HOME/.codex/config.toml"
create_symlink "${PROJECT_ROOT}/configs/codex/AGENTS.toml" "$HOME/.codex/AGENTS.toml"
create_symlink "${PROJECT_ROOT}/configs/codex/prompts" "$HOME/.codex/prompts"
create_symlink "${PROJECT_ROOT}/configs/tmux/.tmux.conf" "$HOME/.tmux.conf"
