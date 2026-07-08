#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib.sh"

export_bash() {
  local dest="$ROOT_DIR/bash"
  safe_mkdir "$dest"
  for f in .bashrc .bash_profile .bash_aliases; do
    if [[ -f "$HOME/$f" ]]; then
      cp -a "$HOME/$f" "$dest/$f"
      log "Exported $f"
    fi
  done
  if [[ -f "$HOME/.local/share/fedora-dotfiles/functions.sh" ]]; then
    cp -a "$HOME/.local/share/fedora-dotfiles/functions.sh" "$dest/functions.sh"
    log "Exported functions.sh"
  elif [[ -f "$ROOT_DIR/bash/functions.sh" ]]; then
    log "functions.sh already up to date in repo"
  fi
}

export_git() {
  local dest="$ROOT_DIR/git"
  safe_mkdir "$dest"
  for f in .gitconfig .gitignore_global; do
    if [[ -f "$HOME/$f" ]]; then
      cp -a "$HOME/$f" "$dest/$f"
      log "Exported $f"
    fi
  done
}

export_oh_my_posh() {
  local src="$HOME/.config/oh-my-posh"
  local dest="$ROOT_DIR/oh-my-posh"
  if [[ -d "$src" ]]; then
    safe_mkdir "$dest"
    find "$src" -maxdepth 1 -type f -name '*.omp.json' -exec cp -a {} "$dest/" \;
    log "Exported oh-my-posh themes"
  fi
}

export_terminal() {
  local dest="$ROOT_DIR/terminal"
  if [[ -d "$HOME/.config/fastfetch" ]]; then
    safe_mkdir "$dest/fastfetch"
    cp -a "$HOME/.config/fastfetch/"* "$dest/fastfetch/" 2>/dev/null || true
    log "Exported fastfetch config"
  fi
  if [[ -f "$HOME/.config/btop/btop.conf" ]]; then
    safe_mkdir "$dest/btop"
    cp -a "$HOME/.config/btop/btop.conf" "$dest/btop/btop.conf"
    log "Exported btop config"
  fi
  if [[ -f "$HOME/.config/starship.toml" ]]; then
    safe_mkdir "$dest/starship"
    cp -a "$HOME/.config/starship.toml" "$dest/starship/starship.toml"
    log "Exported starship config"
  fi
}

export_vscodium() {
  local base="$HOME/.config/VSCodium/User"
  local dest="$ROOT_DIR/vscodium"
  if [[ ! -d "$base" ]]; then
    log "VSCodium user config not found, skipping"
    return 0
  fi
  safe_mkdir "$dest"
  if [[ -f "$base/settings.json" ]]; then
    cp -a "$base/settings.json" "$dest/settings.json"
    log "Exported VSCodium settings.json"
  fi
  if [[ -f "$base/keybindings.json" ]]; then
    cp -a "$base/keybindings.json" "$dest/keybindings.json"
    log "Exported VSCodium keybindings.json"
  fi
  if [[ -d "$base/snippets" ]]; then
    safe_mkdir "$dest/snippets"
    find "$base/snippets" -maxdepth 1 -type f -name '*.json' -exec cp -a {} "$dest/snippets/" \;
    log "Exported VSCodium snippets"
  fi
  local editor=""
  if require_cmd codium; then
    editor="codium"
  elif require_cmd vscodium; then
    editor="vscodium"
  fi
  if [[ -n "$editor" ]]; then
    "$editor" --list-extensions --show-versions 2>/dev/null \
      | sed 's/@.*//' \
      | sort -u > "$dest/extensions.txt"
    log "Exported VSCodium extensions list"
  fi
}

export_docker() {
  local dest="$ROOT_DIR/docker"
  safe_mkdir "$dest"
  if [[ -f "/etc/docker/daemon.json" ]]; then
    sudo cp -a "/etc/docker/daemon.json" "$dest/daemon.json" 2>/dev/null || true
    log "Exported Docker daemon.json"
  elif [[ -f "$HOME/.docker/daemon.json" ]]; then
    cp -a "$HOME/.docker/daemon.json" "$dest/daemon.json"
    log "Exported Docker daemon.json (user)"
  fi
}

export_fonts() {
  local dest="$ROOT_DIR/fonts"
  local found=false
  for font_root in "$HOME/.local/share/fonts" "$HOME/.fonts"; do
    if [[ -d "$font_root" ]]; then
      while IFS= read -r -d '' font; do
        safe_mkdir "$dest"
        cp -a "$font" "$dest/"
        found=true
      done < <(find "$font_root" -maxdepth 1 -type f \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) -print0 2>/dev/null)
    fi
  done
  if $found; then
    log "Exported fonts"
  else
    log "No custom fonts found"
  fi
}

export_ssh() {
  local dest="$ROOT_DIR/ssh"
  safe_mkdir "$dest"
  if [[ -f "$HOME/.ssh/config" ]]; then
    cp -a "$HOME/.ssh/config" "$dest/config"
    log "Exported SSH config"
  fi
}

export_kde() {
  local dest="$ROOT_DIR/kde"
  safe_mkdir "$dest"

  for f in kwinrc konsolerc kcminputrc kdeglobals; do
    if [[ -f "$HOME/.config/$f" ]]; then
      safe_mkdir "$dest/kwin"
      cp -a "$HOME/.config/$f" "$dest/kwin/$f"
      log "Exported KDE $f"
    fi
  done

  if [[ -f "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" ]]; then
    safe_mkdir "$dest/plasma"
    cp -a "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" "$dest/plasma/"
    log "Exported plasma appletsrc"
  fi

  if [[ -d "$HOME/.local/share/konsole" ]]; then
    safe_mkdir "$dest/konsole"
    find "$HOME/.local/share/konsole" -maxdepth 1 -type f \
      \( -name '*.profile' -o -name '*.colorscheme' -o -name '*.schema' \) \
      -exec cp -a {} "$dest/konsole/" \;
    log "Exported Konsole profiles"
  fi

  if [[ -d "$HOME/.local/share/color-schemes" ]]; then
    safe_mkdir "$dest/color-schemes"
    find "$HOME/.local/share/color-schemes" -maxdepth 1 -type f -name '*.colors' \
      -exec cp -a {} "$dest/color-schemes/" \;
    log "Exported color schemes"
  fi

  if [[ -d "$HOME/.local/share/icons" ]]; then
    local has_custom=false
    for d in "$HOME/.local/share/icons"/*/; do
      [[ -d "$d" ]] || continue
      local name
      name="$(basename "$d")"
      case "$name" in
        breeze*|oxygen*|hicolor|default|handcursor*) continue ;;
      esac
      safe_mkdir "$dest/icons/$name"
      cp -a "$d"* "$dest/icons/$name/" 2>/dev/null || true
      has_custom=true
    done
    if $has_custom; then
      log "Exported custom icon themes"
    fi
  fi

  if [[ -d "$HOME/.local/share/wallpapers" ]]; then
    local has_wallpapers=false
    for d in "$HOME/.local/share/wallpapers"/*/; do
      [[ -d "$d" ]] || continue
      local name
      name="$(basename "$d")"
      safe_mkdir "$dest/wallpapers/$name"
      cp -a "$d"* "$dest/wallpapers/$name/" 2>/dev/null || true
      has_wallpapers=true
    done
    if $has_wallpapers; then
      log "Exported wallpapers"
    fi
  fi
}

export_packages() {
  local dest="$ROOT_DIR/packages"
  safe_mkdir "$dest"

  if require_cmd dnf; then
    dnf repoquery --userinstalled --qf '%{name}\n' 2>/dev/null \
      | grep -v '^$' | sort -u > "$dest/dnf-packages.txt" || true
    log "Exported DNF package list"
  fi

  if require_cmd flatpak; then
    flatpak list --app --columns=application 2>/dev/null \
      | grep -v '^$' | sort -u > "$dest/flatpak-packages.txt" || true
    log "Exported Flatpak package list"
  fi

  if require_cmd cargo; then
    cargo install --list 2>/dev/null \
      | awk '/^[^[:space:]]/ {print $1}' | sort -u > "$dest/cargo-packages.txt" || true
    log "Exported cargo package list"
  fi

  if require_cmd go; then
    local gobin
    gobin="$(go env GOPATH)/bin"
    if [[ -d "$gobin" ]]; then
      find "$gobin" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null \
        | sort -u > "$dest/go-binaries.txt" || true
    fi
    log "Exported go binary list"
  fi

  if require_cmd npm; then
    npm list -g --depth=0 --parseable 2>/dev/null \
      | tail -n +2 | xargs -r -n1 basename | sort -u > "$dest/npm-global-packages.txt" || true
    log "Exported npm global package list"
  fi

  if require_cmd pipx; then
    pipx list --short 2>/dev/null \
      | grep -v '^$' | sort -u > "$dest/pipx-packages.txt" || true
    log "Exported pipx package list"
  fi

  if require_cmd python3; then
    python3 -m pip list --user --format=freeze 2>/dev/null \
      | grep -v '^$' | sort -u > "$dest/pip-packages.txt" || true
    log "Exported pip package list"
  fi
}

main() {
  local sections=("$@")

  if [[ ${#sections[@]} -eq 0 ]]; then
    sections=(bash git oh-my-posh terminal vscodium docker fonts ssh kde packages)
  fi

  log "Starting export from live system to repository"

  for section in "${sections[@]}"; do
    case "$section" in
      bash)       export_bash ;;
      git)        export_git ;;
      oh-my-posh) export_oh_my_posh ;;
      terminal)   export_terminal ;;
      vscodium)   export_vscodium ;;
      docker)     export_docker ;;
      fonts)      export_fonts ;;
      ssh)        export_ssh ;;
      kde)        export_kde ;;
      packages)   export_packages ;;
      all)        export_bash; export_git; export_oh_my_posh; export_terminal
                  export_vscodium; export_docker; export_fonts; export_ssh
                  export_kde; export_packages ;;
      list)
        echo "Available sections: bash git oh-my-posh terminal vscodium docker fonts ssh kde packages all"
        ;;
      *)
        log "Unknown section: $section"
        echo "Usage: $0 [section...]"
        echo "Sections: bash git oh-my-posh terminal vscodium docker fonts ssh kde packages all"
        exit 1
        ;;
    esac
  done

  log "Export complete"
}

main "$@"
