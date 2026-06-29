# Fonts

This directory is for user-installed fonts that you want to restore on a new machine.

## What to keep

- Nerd Fonts installed in your home directory
- font files copied from personal archives

## What to avoid

- system fonts under `/usr/share/fonts`
- private or licensed fonts you cannot redistribute

## Restore behavior

The bootstrap script copies any `.ttf`, `.otf`, or `.ttc` files found here into `~/.local/share/fonts`.

