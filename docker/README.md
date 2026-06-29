# Docker

This directory stores non-sensitive Docker configuration.

## Safe files

- `daemon.json`
- `compose-snippets.md`
- example client config files without credentials

## Not safe to commit

- `~/.docker/config.json` with registry tokens
- certificate private keys
- swarm or registry secrets

