#!/usr/bin/env bash

pathprepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

pathappend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$PATH:$1" ;;
  esac
}

mkcd() {
  mkdir -p "$1" && cd "$1"
}

extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.gz|*.tgz) tar -xzf "$1" ;;
      *.tar.bz2) tar -xjf "$1" ;;
      *.tar.xz) tar -xJf "$1" ;;
      *.zip) unzip "$1" ;;
      *) printf 'extract: unsupported file %s\n' "$1" >&2; return 1 ;;
    esac
  fi
}

reload_bash() {
  # Reload the current shell configuration without closing the terminal.
  source "$HOME/.bashrc"
}

