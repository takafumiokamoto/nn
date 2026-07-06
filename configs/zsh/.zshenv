export PATH="$HOME/.local/bin:$PATH"
export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml

if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    alias v="'/mnt/c/Program Files/Neovide/Neovide.exe' --wsl"
fi
