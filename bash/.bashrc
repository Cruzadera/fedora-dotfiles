# Fedora KDE Bash configuration

case $- in
  *i*) ;;
  *) return ;;
esac

export EDITOR="${EDITOR:-vscodium}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export BROWSER="${BROWSER:-firefox}"
export LANG="${LANG:-en_US.UTF-8}"

if [[ -z "${DOTFILES_HOME:-}" ]]; then
  if command -v readlink >/dev/null 2>&1; then
    DOTFILES_HOME="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
  else
    DOTFILES_HOME="$HOME/fedora-dotfiles"
  fi
fi
export DOTFILES_HOME

if [[ -f "$HOME/.local/share/fedora-dotfiles/functions.sh" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.local/share/fedora-dotfiles/functions.sh"
else
  # shellcheck disable=SC1090
  source "$DOTFILES_HOME/bash/functions.sh"
fi

export GOPATH="${GOPATH:-$HOME/go}"
export GOBIN="${GOBIN:-$HOME/go/bin}"
export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk}"
export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
export DOCKER_HOST="${DOCKER_HOST:-unix:///var/run/docker.sock}"

pathprepend "$HOME/.local/bin"
pathprepend "$GOBIN"
pathprepend "$HOME/.cargo/bin"
pathprepend "$HOME/.npm-global/bin"
pathprepend "$HOME/.dotnet/tools"

if [[ -d "$SDKMAN_DIR/bin" ]]; then
  # shellcheck disable=SC1090
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

if [[ -f "$HOME/.bash_aliases" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.bash_aliases"
fi

export PATH

PS1='\u@\h:\w\$ '
