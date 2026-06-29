# SSH

This folder stores SSH client configuration only.

## Safe contents

- `config`
- `known_hosts` if you want to keep trusted hosts under version control

## Never commit

- `id_rsa`, `id_ed25519`, or any other private key
- certificates, agent sockets, or encrypted key backups

## Suggested setup

1. Place private keys in `~/.ssh/` locally.
2. Keep public keys separate if you want to document them.
3. Copy only the SSH client config into this repository.

