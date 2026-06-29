#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:-/home/$USER}"

source "$ROOT_DIR/scripts/lib.sh"

main() {
  local action="${1:-install}"
  shift || true

  case "$action" in
    install)
      install_all "$@"
      ;;
    backup)
      backup_all "$@"
      ;;
    restore)
      restore_all "$@"
      ;;
    update)
      update_manifests "$@"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [install|backup|restore|update]
EOF
}

main "$@"

