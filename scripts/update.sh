#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib.sh"

safe_mkdir "$ROOT_DIR/backups"

if require_cmd dnf; then
  dnf repoquery --userinstalled --qf '%{name}' | sort -u > "$ROOT_DIR/packages/dnf-packages.txt" || true
fi

if require_cmd flatpak; then
  flatpak list --app --columns=application | sort -u > "$ROOT_DIR/packages/flatpak-packages.txt" || true
fi

if require_cmd cargo; then
  cargo install --list | awk '/^[^[:space:]]/ {print $1}' | sort -u > "$ROOT_DIR/packages/cargo-packages.txt" || true
fi

if require_cmd go; then
  gobin="$(go env GOPATH)/bin"
  if [[ -d "$gobin" ]]; then
    find "$gobin" -maxdepth 1 -type f -printf '%f\n' | sort -u > "$ROOT_DIR/packages/go-binaries.txt" || true
  fi
fi

if require_cmd npm; then
  npm list -g --depth=0 --parseable | tail -n +2 | xargs -r -n1 basename | sort -u > "$ROOT_DIR/packages/npm-global-packages.txt" || true
fi

if require_cmd pipx; then
  pipx list --short | sort -u > "$ROOT_DIR/packages/pipx-packages.txt" || true
fi

if require_cmd python3; then
  python3 -m pip list --user --format=freeze | sort -u > "$ROOT_DIR/packages/pip-packages.txt" || true
fi

log "Package manifests refreshed"
