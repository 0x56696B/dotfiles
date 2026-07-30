# CLAUDE.md

Guidance for Claude Code in this repo.

## What

Personal dotfiles = Ansible playbook. Targets macOS (`Darwin`) + Debian Linux. Runs local or remote hosts from vault-encrypted inventory.

## Driver

`bin/dotfiles` = Python wrapper → `ansible-playbook main.yml`. Handles vault pw, conditional `--ask-become-pass`, host/role filter. Use it, not raw `ansible-playbook`.

```bash
bin/dotfiles -h                          # help
bin/dotfiles -lr                         # list roles
bin/dotfiles -lh                         # list hosts
bin/dotfiles -m local_mac -r neovim      # one role, one host
bin/dotfiles -m local_mac -r zsh -r git  # multiple -r
bin/dotfiles                             # all roles, all hosts
bin/dotfiles --debug ...                 # adds -vvv
bin/dotfiles ... -- --check --diff       # raw flags → ansible-playbook
```

Args after bare `--` (or unknown via `REMAINDER`) → forwarded verbatim.

## Vault

- `vault.secret` @ repo root = vault pw file (gitignored). Present → `--vault-password-file`. Absent → `--ask-vault-password`.
- `inventory/hosts.yml` plaintext. `inventory/host_vars/*.yml` vault-encrypted, may carry `ansible_become_password`. Key set for all targets → skip `--ask-become-pass`.
- Darwin: `--ask-become-pass` only when `system-update` role requested (`bin/dotfiles` L74–77).

Edit encrypted host vars: `ansible-vault edit inventory/host_vars/<host>.yml --vault-password-file vault.secret`.

## Playbook structure

`main.yml` = **dynamic role discovery**. `find`s `roles/*`, includes each. No explicit list. Drop dir under `roles/` → auto-included. `playbooks` extra-var (from `-r`) filters. `exclude_roles` subtracts from "all".

Role shape:

```
roles/<name>/
  tasks/
    main.yml      # OS dispatcher: stat tasks/<os_family>.yml, include if exists
    Darwin.yml    # macOS (usually community.general.homebrew)
    Debian.yml    # Debian/Ubuntu (apt)
  files/          # configs; symlinked local, copied remote
  meta/           # optional helper task files
```

**Load-bearing pattern**: `tasks/main.yml` splits local vs remote. `ansible_connection == "local"` → `roles/<name>/files/` **symlinked** into `$HOME` (repo edits live). Remote → **copied**. Preserve split. Don't unify to single `copy` task.

## Add role

1. `mkdir -p roles/<name>/{tasks,files}`
2. Write `tasks/main.yml`. Model on `roles/git/tasks/main.yml` (pure dotfile) or `roles/neovim/tasks/main.yml` (install + symlink config dir).
3. Add `tasks/Darwin.yml` and/or `tasks/Debian.yml` for packages. Dispatcher skips OS with no match.
4. No registration. `main.yml` discovers next run.

## Bootstrap

`bin/helper_scripts.py`'s `load_setup()` (called from `bin/dotfiles`) installs Ansible + Python on Ubuntu/Arch pre-playbook. macOS: no bootstrap. Homebrew + Ansible assumed present.

## Submodules

`.gitmodules` → `zsh-syntax-highlighting`, `zsh-autosuggestions`, `tpm`. Clone `--recursive` or run `git submodule update --init`. zsh + tmux roles depend on paths.
