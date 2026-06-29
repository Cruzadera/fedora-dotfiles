# KDE export notes

KDE Plasma stores settings in several different locations.

## Common sources

- `~/.config/`
- `~/.local/share/`
- `~/.config/kwinrc`
- `~/.config/konsolerc`
- `~/.config/plasma-org.kde.plasma.desktop-appletsrc`

## Export strategy

- Copy the matching files into the folders in `kde/`.
- Keep each exported area separate so restores stay understandable.
- Re-test after major KDE upgrades because file names can move between releases.

