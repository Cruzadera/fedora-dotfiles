# fedora-dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Fedora KDE](https://img.shields.io/badge/Fedora-KDE-51A2DA?logo=fedora&logoColor=white)](https://fedoraproject.org/kde/)
[![Dotfiles](https://img.shields.io/badge/Status-dotfiles%20template-333333)](#fedora-dotfiles)

Professional Fedora KDE dotfiles for rebuilding a workstation from a clean install.

This repository is designed to help restore a full personal Linux environment on a new machine with a single clone and a small amount of review before applying changes.

Target environment:

- Fedora KDE Edition
- Wayland session
- Bash shell
- VSCodium
- Git
- Oh My Posh
- Docker
- Development tooling

## Features

- Bash configuration split into reusable modules.
- Oh My Posh theme: `roma-gruvbox`.
- Git configuration and global ignore rules.
- VSCodium settings, keybindings, snippets, and extension inventory.
- KDE Plasma, Konsole, and KWin backup structure.
- Wayland-friendly KDE session notes and exports.
- Docker, Fastfetch, and terminal configuration support.
- Package manifests for DNF, Flatpak, Cargo, Go, npm, pipx, and pip.
- Bootstrap, install, backup, restore, and update helper scripts.
- Security-first defaults that avoid storing secrets in Git.
- GitHub Actions validation for JSON and shell syntax.

## Screenshots

Add screenshots to:

- [`oh-my-posh/screenshots/`](oh-my-posh/screenshots/)
- [`docs/`](docs/)

Recommended screenshots:

- Terminal prompt with `roma-gruvbox`.
- KDE desktop with panel and window decoration.
- VSCodium with the exported theme and settings.

## Installation

1. Clone the repository.
2. Review the package manifests and config files.
3. Run the bootstrap script.

```bash
git clone <your-repo-url> fedora-dotfiles
cd fedora-dotfiles
chmod +x install.sh bootstrap.sh scripts/*.sh
./install.sh
```

If you want a staged restore, use:

```bash
./bootstrap.sh backup
./bootstrap.sh restore
```

## Repository structure

```text
fedora-dotfiles/
├── README.md
├── LICENSE
├── install.sh
├── bootstrap.sh
├── packages/
├── bash/
├── oh-my-posh/
├── git/
├── ssh/
├── fonts/
├── kde/
├── vscodium/
├── terminal/
├── docker/
├── scripts/
└── docs/
```

## Customization

- Update your Git identity in [`git/.gitconfig`](git/.gitconfig).
- Review aliases in [`bash/.bash_aliases`](bash/.bash_aliases).
- Tune prompt segments in [`oh-my-posh/roma-gruvbox.omp.json`](oh-my-posh/roma-gruvbox.omp.json).
- Add or remove packages in [`packages/`](packages/).
- Extend VSCodium settings in [`vscodium/settings.json`](vscodium/settings.json).
- Record KDE exports in the matching subfolders under [`kde/`](kde/).

## Supported Fedora versions

This repository targets Fedora KDE Edition on the current stable Fedora release. The scripts are intentionally conservative and should work across recent Fedora releases, but package names and Flatpak IDs may change over time.

## Security

Never commit:

- SSH private keys
- GPG private keys
- passwords or tokens
- API keys
- browser profiles
- shell history
- secret environment files

Keep sensitive files local and restore them manually on each machine.

## License

Licensed under the MIT License. See [`LICENSE`](LICENSE).

## Credits

- Fedora Project
- KDE Plasma
- Oh My Posh
- VSCodium
- Docker
- The Gruvbox color palette community
