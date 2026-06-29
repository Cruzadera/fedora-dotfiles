# Security

This repository is intentionally strict about what may be committed.

## Never upload

- SSH private keys
- GPG private keys
- passwords
- access tokens
- API keys
- browser profiles
- cookies
- shell history files
- secret environment variables

## Safe alternatives

- Commit `*.example` files instead of real secrets.
- Store private keys locally in `~/.ssh/`.
- Keep tokens in your local password manager or secret store.
- Use environment files that stay outside the repository.

