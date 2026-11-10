# Dotfiles verification map

This directory is the maintained source for verifying the user-facing behavior of the Dotfiles installer and the configs it links. Read the index before driving the app, then use the matching feature file as the recipe.

## Baseline preconditions

- Run `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles start` from the repo root.
- Isolated `HOME` is `/tmp/dotfiles-verify-<RUN_ID>/home`. `REAL_HOME` is the operator home.
- `control-dotfiles doctor` prints `SAFE`.
- Never run `./install.sh` with the operator `HOME`.
- Default skip-deps drives use `DOTFILES_CI_SMOKE_INSTALL=1`. Assert the skip lines; do not treat them as a full extras install.
- Full brew/apt install is out of scope for local drives. CI owns `./scripts/ci-smoke-install.sh`.

## Driving conventions

- Start every recipe from a fresh `start` unless the feature says to reuse a skip-deps HOME.
- Treat flags, prompt text, and evidence filenames as literal.
- Drive through `control-dotfiles`. Do not source `install.sh` into the agent shell.
- Restore nothing in the operator home. Isolated HOME is disposable; evidence is not.

## Proof and skip reporting

- Capture transcript, exit code, and HOME before/after for every install drive.
- Mutation proof is `control-dotfiles links` or the backup file contents, not the success banner alone.
- Dry-run proof includes empty `home-diff.txt` and empty `curl.log`.
- Report an unreachable path with the command and the unmet precondition (network, tmux sandbox, missing nvim).
- Do not report a skipped entry point as verified through a different path.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph describing the user-visible behavior. It then uses exactly four H2 sections in this order.

1. `Sub-features` lists short IDs with one line for each behavior.
2. `How to get to it (user POV)` lists every user entry point.
3. `Driving it with control-dotfiles` starts with `Preconditions:` and uses labeled bullets that pair each user action with an exact command and observable result.
4. `Gotchas` lists traps that can waste or invalidate a verification run.

Keep implementation details out of the map. Name only user paths, stable handles, required state, commands, and observable proof.

## Features

- [Dry-run install](./dry-run-install.md) covers preview output, zero HOME writes, and no downloads.
- [Skip-deps install](./skip-deps-install.md) covers confirm-yes linking, platform targets, CI-smoke skips, and idempotence.
- [Backup existing files](./backup-existing-files.md) covers backing up regular files and leaving existing symlinks uncopied.
- [Abort and reject](./abort-and-reject.md) covers answering `n`, unknown flags, and unsupported platforms.
- [Post-install startup](./post-install-startup.md) covers doctor link checks, zsh aliases, tmux parse, and the Neovim contract.
