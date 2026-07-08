#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib.sh"

safe_mkdir "$ROOT_DIR/packages"

if require_cmd dnf; then
  dnf repoquery --userinstalled --qf '%{name}\n' 2>/dev/null \
    | grep -v '^$' | sort -u > "$ROOT_DIR/packages/dnf-packages.txt" || true
fi

if require_cmd flatpak; then
  flatpak list --app --columns=application 2>/dev/null \
    | grep -v '^$' | sort -u > "$ROOT_DIR/packages/flatpak-packages.txt" || true
fi

if require_cmd cargo; then
  cargo install --list 2>/dev/null \
    | awk '/^[^[:space:]]/ {print $1}' | sort -u > "$ROOT_DIR/packages/cargo-packages.txt" || true
fi

if require_cmd go; then
  gobin="$(go env GOPATH)/bin"
  if [[ -d "$gobin" ]]; then
    > "$ROOT_DIR/packages/go-binaries.txt"
    for bin in "$gobin"/*; do
      [[ -f "$bin" ]] || continue
      modpath=$(go version -m "$bin" 2>/dev/null | awk '/^\tmod / {print $2}' | head -1)
      if [[ -n "$modpath" ]]; then
        echo "${modpath}@latest" >> "$ROOT_DIR/packages/go-binaries.txt"
      fi
    done
    sort -u -o "$ROOT_DIR/packages/go-binaries.txt" "$ROOT_DIR/packages/go-binaries.txt"
  fi
fi

if require_cmd npm; then
  npm list -g --depth=0 --parseable 2>/dev/null \
    | tail -n +2 | xargs -r -n1 basename | sort -u > "$ROOT_DIR/packages/npm-global-packages.txt" || true
fi

if require_cmd pipx; then
  pipx list --short 2>/dev/null \
    | grep -v '^$' | sort -u > "$ROOT_DIR/packages/pipx-packages.txt" || true
fi

if require_cmd python3; then
  python3 -m pip list --user --format=freeze 2>/dev/null \
    | grep -v '^$' | sort -u > "$ROOT_DIR/packages/pip-packages.txt" || true
fi

log "Package manifests refreshed"
