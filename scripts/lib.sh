#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="${HOME:-/home/$USER}"
BACKUP_DIR="$ROOT_DIR/backups"

log() { printf '[fedora-dotfiles] %s\n' "$*"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || return 1
}

strip_comments() {
  grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$1"
}

safe_mkdir() {
  mkdir -p "$1"
}

backup_path() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    cp -a "$path" "$path.bak.$(date +%Y%m%d%H%M%S)"
  fi
}

link_file() {
  local source="$1"
  local target="$2"
  safe_mkdir "$(dirname "$target")"
  backup_path "$target"
  ln -sfn "$source" "$target"
}

copy_file() {
  local source="$1"
  local target="$2"
  safe_mkdir "$(dirname "$target")"
  cp -a "$source" "$target"
}

install_dnf_packages() {
  local manifest="$ROOT_DIR/packages/dnf-packages.txt"
  if ! require_cmd dnf; then
    log "dnf not available, skipping system packages"
    return 0
  fi
  mapfile -t packages < <(strip_comments "$manifest" || true)
  if ((${#packages[@]})); then
    sudo dnf install -y "${packages[@]}"
  fi
}

install_flatpak_packages() {
  local manifest="$ROOT_DIR/packages/flatpak-packages.txt"
  if ! require_cmd flatpak; then
    log "flatpak not available, skipping Flatpak packages"
    return 0
  fi
  mapfile -t packages < <(strip_comments "$manifest" || true)
  for package in "${packages[@]}"; do
    flatpak install -y flathub "$package"
  done
}

install_pip_packages() {
  local manifest="$ROOT_DIR/packages/pip-packages.txt"
  if ! require_cmd python3; then
    return 0
  fi
  mapfile -t packages < <(strip_comments "$manifest" || true)
  if ((${#packages[@]})); then
    python3 -m pip install --user "${packages[@]}"
  fi
}

install_cargo_packages() {
  local manifest="$ROOT_DIR/packages/cargo-packages.txt"
  if ! require_cmd cargo; then
    return 0
  fi
  mapfile -t packages < <(strip_comments "$manifest" || true)
  for package in "${packages[@]}"; do
    cargo install "$package"
  done
}

install_go_binaries() {
  local manifest="$ROOT_DIR/packages/go-binaries.txt"
  if ! require_cmd go; then
    return 0
  fi
  mapfile -t packages < <(strip_comments "$manifest" || true)
  for package in "${packages[@]}"; do
    go install "$package"
  done
}

install_npm_packages() {
  local manifest="$ROOT_DIR/packages/npm-global-packages.txt"
  if ! require_cmd npm; then
    return 0
  fi
  mapfile -t packages < <(strip_comments "$manifest" || true)
  if ((${#packages[@]})); then
    npm install -g "${packages[@]}"
  fi
}

install_pipx_packages() {
  local manifest="$ROOT_DIR/packages/pipx-packages.txt"
  if ! require_cmd pipx; then
    return 0
  fi
  mapfile -t packages < <(strip_comments "$manifest" || true)
  for package in "${packages[@]}"; do
    pipx install "$package"
  done
}

install_oh_my_posh() {
  if ! require_cmd oh-my-posh; then
    if require_cmd dnf; then
      sudo dnf install -y oh-my-posh || true
    else
      log "oh-my-posh is not installed yet; install it with dnf or the upstream installer"
    fi
  fi
  link_file "$ROOT_DIR/oh-my-posh/roma-gruvbox.omp.json" "$HOME_DIR/.config/oh-my-posh/roma-gruvbox.omp.json"
}

install_nerd_fonts() {
  local fonts_dir="$ROOT_DIR/fonts"
  safe_mkdir "$HOME_DIR/.local/share/fonts"
  find "$fonts_dir" -maxdepth 1 -type f \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) -exec cp -a {} "$HOME_DIR/.local/share/fonts/" \; 2>/dev/null || true
  fc-cache -f "$HOME_DIR/.local/share/fonts" >/dev/null 2>&1 || true
}

install_bash_config() {
  link_file "$ROOT_DIR/bash/.bashrc" "$HOME_DIR/.bashrc"
  link_file "$ROOT_DIR/bash/.bash_profile" "$HOME_DIR/.bash_profile"
  link_file "$ROOT_DIR/bash/.bash_aliases" "$HOME_DIR/.bash_aliases"
  link_file "$ROOT_DIR/bash/functions.sh" "$HOME_DIR/.local/share/fedora-dotfiles/functions.sh"
}

install_git_config() {
  link_file "$ROOT_DIR/git/.gitconfig" "$HOME_DIR/.gitconfig"
  link_file "$ROOT_DIR/git/.gitignore_global" "$HOME_DIR/.gitignore_global"
}

install_ssh_config() {
  if [[ -f "$ROOT_DIR/ssh/config" ]]; then
    safe_mkdir "$HOME_DIR/.ssh"
    link_file "$ROOT_DIR/ssh/config" "$HOME_DIR/.ssh/config"
  fi
  if [[ -f "$ROOT_DIR/ssh/known_hosts" ]]; then
    safe_mkdir "$HOME_DIR/.ssh"
    copy_file "$ROOT_DIR/ssh/known_hosts" "$HOME_DIR/.ssh/known_hosts"
  fi
}

install_vscodium_config() {
  local base="$HOME_DIR/.config/VSCodium/User"
  link_file "$ROOT_DIR/vscodium/settings.json" "$base/settings.json"
  link_file "$ROOT_DIR/vscodium/keybindings.json" "$base/keybindings.json"
}

install_vscodium_extensions() {
  local manifest="$ROOT_DIR/vscodium/extensions.txt"
  if ! require_cmd codium && ! require_cmd vscodium; then
    return 0
  fi
  local editor="codium"
  if ! require_cmd codium; then
    editor="vscodium"
  fi
  mapfile -t extensions < <(strip_comments "$manifest" || true)
  for extension in "${extensions[@]}"; do
    "$editor" --install-extension "$extension" --force || true
  done
}

install_terminal_config() {
  link_file "$ROOT_DIR/terminal/fastfetch/config.jsonc" "$HOME_DIR/.config/fastfetch/config.jsonc"
  link_file "$ROOT_DIR/terminal/btop/btop.conf" "$HOME_DIR/.config/btop/btop.conf"
}

install_docker_config() {
  link_file "$ROOT_DIR/docker/daemon.json" "$HOME_DIR/.config/docker/daemon.json"
  link_file "$ROOT_DIR/docker/config.json.example" "$HOME_DIR/.docker/config.json.example"
}

restore_kde_config() {
  local src="$ROOT_DIR/kde"
  if [[ -d "$src/plasma" ]]; then
    safe_mkdir "$HOME_DIR/.config"
    cp -a "$src/plasma"/. "$HOME_DIR/.config/" 2>/dev/null || true
  fi
  if [[ -d "$src/konsole" ]]; then
    safe_mkdir "$HOME_DIR/.local/share/konsole"
    cp -a "$src/konsole"/. "$HOME_DIR/.local/share/konsole/" 2>/dev/null || true
  fi
  if [[ -d "$src/kwin" ]]; then
    safe_mkdir "$HOME_DIR/.config"
    cp -a "$src/kwin"/. "$HOME_DIR/.config/" 2>/dev/null || true
  fi
  if [[ -d "$src/color-schemes" ]]; then
    safe_mkdir "$HOME_DIR/.local/share/color-schemes"
    cp -a "$src/color-schemes"/. "$HOME_DIR/.local/share/color-schemes/" 2>/dev/null || true
  fi
  if [[ -d "$src/icons" ]]; then
    safe_mkdir "$HOME_DIR/.local/share/icons"
    cp -a "$src/icons"/. "$HOME_DIR/.local/share/icons/" 2>/dev/null || true
  fi
  if [[ -d "$src/wallpapers" ]]; then
    safe_mkdir "$HOME_DIR/.local/share/wallpapers"
    cp -a "$src/wallpapers"/. "$HOME_DIR/.local/share/wallpapers/" 2>/dev/null || true
  fi
}

backup_all() {
  safe_mkdir "$BACKUP_DIR"
  "$ROOT_DIR/scripts/backup.sh"
}

restore_all() {
  install_bash_config
  install_git_config
  install_ssh_config
  install_vscodium_config
  install_terminal_config
  install_docker_config
  install_oh_my_posh
  restore_kde_config
  install_vscodium_extensions
}

install_all() {
  install_dnf_packages
  install_flatpak_packages
  install_pip_packages
  install_cargo_packages
  install_go_binaries
  install_npm_packages
  install_pipx_packages
  install_nerd_fonts
  restore_all
}

update_manifests() {
  "$ROOT_DIR/scripts/update.sh"
}
