#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib.sh"

timestamp="$(date +%Y%m%d-%H%M%S)"
dest="$ROOT_DIR/backups/$timestamp"

safe_mkdir "$dest"

log "Creating backup snapshot in $dest"

if require_cmd dnf; then
  dnf repoquery --userinstalled --qf '%{name}' | sort -u > "$dest/dnf-packages.txt" || true
fi

if require_cmd flatpak; then
  flatpak list --app --columns=application | sort -u > "$dest/flatpak-packages.txt" || true
fi

if require_cmd npm; then
  npm list -g --depth=0 --parseable | tail -n +2 | xargs -r -n1 basename | sort -u > "$dest/npm-global-packages.txt" || true
fi

if require_cmd cargo; then
  cargo install --list | awk '/^[^[:space:]]/ {print $1}' | sort -u > "$dest/cargo-packages.txt" || true
fi

if require_cmd pipx; then
  pipx list --short | sort -u > "$dest/pipx-packages.txt" || true
fi

if require_cmd python3; then
  python3 -m pip list --user --format=freeze | sort -u > "$dest/pip-packages.txt" || true
fi

if require_cmd go; then
  gobin="$(go env GOPATH)/bin"
  if [[ -d "$gobin" ]]; then
    find "$gobin" -maxdepth 1 -type f -printf '%f\n' | sort -u > "$dest/go-binaries.txt" || true
  fi
fi

safe_mkdir "$dest/fonts"
for font_root in "$HOME/.local/share/fonts" "$HOME/.fonts"; do
  if [[ -d "$font_root" ]]; then
    find "$font_root" -type f \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) -exec cp -a {} "$dest/fonts/" \; 2>/dev/null || true
  fi
done

safe_mkdir "$dest/ssh"
if [[ -f "$HOME/.ssh/config" ]]; then
  cp -a "$HOME/.ssh/config" "$dest/ssh/config"
fi
if [[ -f "$HOME/.ssh/known_hosts" ]]; then
  cp -a "$HOME/.ssh/known_hosts" "$dest/ssh/known_hosts"
fi

cp -a "$ROOT_DIR"/bash "$dest/" 2>/dev/null || true
cp -a "$ROOT_DIR"/git "$dest/" 2>/dev/null || true
cp -a "$ROOT_DIR"/vscodium "$dest/" 2>/dev/null || true
cp -a "$ROOT_DIR"/oh-my-posh "$dest/" 2>/dev/null || true
cp -a "$ROOT_DIR"/terminal "$dest/" 2>/dev/null || true
cp -a "$ROOT_DIR"/docker "$dest/" 2>/dev/null || true

log "Backup complete"
