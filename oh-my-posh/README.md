# Oh My Posh

The custom theme for this repository is [`roma-gruvbox.omp.json`](roma-gruvbox.omp.json).

## Installation

1. Install Oh My Posh on Fedora.
2. Copy or link the theme into your config directory.
3. Point your Bash profile at the theme file.

Example:

```bash
oh-my-posh init bash --config ~/.config/oh-my-posh/roma-gruvbox.omp.json
```

## Customization

- Adjust palette values in the JSON theme.
- Tweak segment ordering for your workflow.
- Remove language segments you do not use.

## Screenshots

Add prompt screenshots to [`screenshots/`](screenshots/).

## Color palette

The theme uses a Gruvbox-inspired palette:

- `#282828`
- `#3C3836`
- `#32302F`
- `#EBDBB2`
- `#A9B665`
- `#D8A657`
- `#7DAEA3`
- `#89B4FA`
- `#E78A4E`
- `#EA6962`
- `#928374`

## Supported Nerd Fonts

Any modern Nerd Font with the following glyphs should work well:

- powerline separators
- folder icons
- Git branch icons
- language logos
- status glyphs used by Oh My Posh segments

Recommended choices:

- JetBrainsMono Nerd Font
- MesloLGS Nerd Font
- Hack Nerd Font
- FiraCode Nerd Font
