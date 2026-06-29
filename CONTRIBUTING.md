# Contributing

Thanks for helping improve this dotfiles repository.

## Workflow

1. Open an issue or draft pull request first for larger changes.
2. Keep config files small, modular, and documented.
3. Never commit secrets, tokens, browser profiles, or private keys.
4. Run the validation workflow locally when possible.

## Style guide

- Prefer portable Bash.
- Use ASCII unless a file already needs Unicode, such as the Oh My Posh theme.
- Keep package manifests sorted and easy to scan.
- Document any destructive or machine-specific behavior in `docs/`.

## Testing

Before opening a PR, check:

- JSON syntax
- shell syntax
- path references in README files

