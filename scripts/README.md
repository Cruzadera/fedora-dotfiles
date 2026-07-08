# Scripts

Helper scripts for day-to-day maintenance.

## Files

- `export.sh`: export live system configs and package lists into the repository
- `backup.sh`: create a timestamped snapshot of the live system into `backups/`
- `restore.sh`: apply the repository config to the current user
- `update.sh`: refresh package manifests from the current machine
- `lib.sh`: shared functions used by all scripts

## Typical workflow

```bash
# On current workstation — capture everything
./scripts/export.sh
git add . && git commit -m "export: update configs" && git push

# On a new Fedora machine — reproduce the environment
git clone <repo> ~/fedora-dotfiles
cd ~/fedora-dotfiles
./bootstrap.sh install
```

## Selective export

```bash
./scripts/export.sh bash git packages
./scripts/export.sh kde
./scripts/export.sh all
```
