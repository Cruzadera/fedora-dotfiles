#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib.sh"

timestamp="$(date +%Y%m%d-%H%M%S)"
dest="$ROOT_DIR/backups/$timestamp"

safe_mkdir "$dest"

log "Creating backup snapshot in $dest"

if require_cmd dnf; then
  dnf repoquery --userinstalled --qf '%{name}\n' 2>/dev/null \
    | grep -v '^$' | sort -u > "$dest/dnf-packages.txt" || true
fi

if require_cmd flatpak; then
  flatpak list --app --columns=application 2>/dev/null \
    | grep -v '^$' | sort -u > "$dest/flatpak-packages.txt" || true
fi

if require_cmd npm; then
  npm list -g --depth=0 --parseable 2>/dev/null \
    | tail -n +2 | xargs -r -n1 basename | sort -u > "$dest/npm-global-packages.txt" || true
fi

if require_cmd cargo; then
  cargo install --list 2>/dev/null \
    | awk '/^[^[:space:]]/ {print $1}' | sort -u > "$dest/cargo-packages.txt" || true
fi

if require_cmd pipx; then
  pipx list --short 2>/dev/null \
    | grep -v '^$' | sort -u > "$dest/pipx-packages.txt" || true
fi

if require_cmd python3; then
  python3 -m pip list --user --format=freeze 2>/dev/null \
    | grep -v '^$' | sort -u > "$dest/pip-packages.txt" || true
fi

if require_cmd go; then
  gobin="$(go env GOPATH)/bin"
  if [[ -d "$gobin" ]]; then
    find "$gobin" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null \
      | sort -u > "$dest/go-binaries.txt" || true
  fi
fi

safe_mkdir "$dest/fonts"
for font_root in "$HOME/.local/share/fonts" "$HOME/.fonts"; do
  if [[ -d "$font_root" ]]; then
    find "$font_root" -maxdepth 1 -type f \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) \
      -exec cp -a {} "$dest/fonts/" \; 2>/dev/null || true
  fi
done

safe_mkdir "$dest/ssh"
if [[ -f "$HOME/.ssh/config" ]]; then
  cp -a "$HOME/.ssh/config" "$dest/ssh/config"
fi
if [[ -f "$HOME/.ssh/known_hosts" ]]; then
  cp -a "$HOME/.ssh/known_hosts" "$dest/ssh/known_hosts"
fi

for f in .bashrc .bash_profile .bash_aliases; do
  if [[ -f "$HOME/$f" ]]; then
    safe_mkdir "$dest/bash"
    cp -a "$HOME/$f" "$dest/bash/$f"
  fi
done
if [[ -f "$HOME/.local/share/fedora-dotfiles/functions.sh" ]]; then
  safe_mkdir "$dest/bash"
  cp -a "$HOME/.local/share/fedora-dotfiles/functions.sh" "$dest/bash/functions.sh"
fi

for f in .gitconfig .gitignore_global; do
  if [[ -f "$HOME/$f" ]]; then
    safe_mkdir "$dest/git"
    cp -a "$HOME/$f" "$dest/git/$f"
  fi
done

if [[ -d "$HOME/.config/VSCodium/User" ]]; then
  safe_mkdir "$dest/vscodium"
  if [[ -f "$HOME/.config/VSCodium/User/settings.json" ]]; then
    cp -a "$HOME/.config/VSCodium/User/settings.json" "$dest/vscodium/"
  fi
  if [[ -f "$HOME/.config/VSCodium/User/keybindings.json" ]]; then
    cp -a "$HOME/.config/VSCodium/User/keybindings.json" "$dest/vscodium/"
  fi
  if [[ -d "$HOME/.config/VSCodium/User/snippets" ]]; then
    cp -a "$HOME/.config/VSCodium/User/snippets" "$dest/vscodium/"
  fi
  editor=""
  if require_cmd codium; then editor="codium"
  elif require_cmd vscodium; then editor="vscodium"; fi
  if [[ -n "$editor" ]]; then
    "$editor" --list-extensions --show-versions 2>/dev/null \
      | sed 's/@.*//' | sort -u > "$dest/vscodium/extensions.txt" || true
  fi
fi

if [[ -d "$HOME/.config/oh-my-posh" ]]; then
  safe_mkdir "$dest/oh-my-posh"
  find "$HOME/.config/oh-my-posh" -maxdepth 1 -type f -name '*.omp.json' \
    -exec cp -a {} "$dest/oh-my-posh/" \;
fi

safe_mkdir "$dest/terminal"
if [[ -d "$HOME/.config/fastfetch" ]]; then
  cp -a "$HOME/.config/fastfetch" "$dest/terminal/"
fi
if [[ -f "$HOME/.config/btop/btop.conf" ]]; then
  safe_mkdir "$dest/terminal/btop"
  cp -a "$HOME/.config/btop/btop.conf" "$dest/terminal/btop/btop.conf"
fi
if [[ -f "$HOME/.config/starship.toml" ]]; then
  safe_mkdir "$dest/terminal/starship"
  cp -a "$HOME/.config/starship.toml" "$dest/terminal/starship/starship.toml"
fi

if [[ -f "/etc/docker/daemon.json" ]]; then
  safe_mkdir "$dest/docker"
  sudo cp -a "/etc/docker/daemon.json" "$dest/docker/daemon.json" 2>/dev/null || true
elif [[ -f "$HOME/.docker/daemon.json" ]]; then
  safe_mkdir "$dest/docker"
  cp -a "$HOME/.docker/daemon.json" "$dest/docker/daemon.json"
fi

safe_mkdir "$dest/kde"
for f in kwinrc konsolerc kcminputrc kdeglobals; do
  if [[ -f "$HOME/.config/$f" ]]; then
    safe_mkdir "$dest/kde/kwin"
    cp -a "$HOME/.config/$f" "$dest/kde/kwin/$f"
  fi
done
if [[ -f "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" ]]; then
  safe_mkdir "$dest/kde/plasma"
  cp -a "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" "$dest/kde/plasma/"
fi
if [[ -d "$HOME/.local/share/konsole" ]]; then
  safe_mkdir "$dest/kde/konsole"
  find "$HOME/.local/share/konsole" -maxdepth 1 -type f \
    \( -name '*.profile' -o -name '*.colorscheme' -o -name '*.schema' \) \
    -exec cp -a {} "$dest/kde/konsole/" \;
fi
if [[ -d "$HOME/.local/share/color-schemes" ]]; then
  safe_mkdir "$dest/kde/color-schemes"
  find "$HOME/.local/share/color-schemes" -maxdepth 1 -type f -name '*.colors' \
    -exec cp -a {} "$dest/kde/color-schemes/" \;
fi

log "Backup complete"
