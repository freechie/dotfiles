---
name: verify-dotfiles
description: Drive the Dotfiles installer CLI (install.sh) and post-install zsh/tmux/Neovim checks in an isolated HOME. Use when verifying install, doctor, symlink, backup, or startup behavior.
---

# Verify Dotfiles

Primary surface is the installer CLI `./install.sh`. Users run it from a clone, confirm `y`/`n`, and get symlinks plus optional package setup. Secondary surfaces after install: zsh/bash, tmux, Neovim, Ghostty, `scripts/doctor.sh`. This skill drives the installer the way a user does, then smokes the configs it linked. It does not drive the operator's live `$HOME`.

`./test.sh` (Bats) is the repo test suite. Use it for extra signal. Proofs for this skill go through `control-dotfiles` so HOME, transcripts, and teardown stay isolated.

## Launch

There is no long-lived server. Launch means create one isolated HOME, then run each drive in that HOME.

From the repo root:

```bash
./.cursor/skills/verify-dotfiles/scripts/control-dotfiles start
```

Ready when stdout includes `RUN_ID=...`, `HOME=/tmp/dotfiles-verify-<id>/home`, and `REAL_HOME` equal to the operator's passwd home (not `$HOME`, and not the verify path). Optional: `--platform macos` or `--platform linux` to force link targets. Default is `uname`.

Reuse that run for sequential features. Set `DOTFILES_VERIFY_RUN=<id>` to select a run instead of the last `start`. Do not start a second driver against the same `RUN_ID`. Separate `start` invocations may run side by side; each has its own `/tmp/dotfiles-verify-*` directory.

Teardown (after the last drive, including retries):

```bash
./.cursor/skills/verify-dotfiles/scripts/control-dotfiles cleanup
```

Cleanup deletes `/tmp/dotfiles-verify-<id>` only. Evidence stays under `.cursor/skills/verify-dotfiles/evidence/<id>/`.

## Doctor

Run before the first drive, after any failed drive, and on a fresh run:

```bash
./.cursor/skills/verify-dotfiles/scripts/control-dotfiles doctor
```

Drive only when the last line is `SAFE`. Doctor is read-only. It checks `install.sh` is executable, the isolated HOME is not `REAL_HOME`, `REAL_HOME` matches the passwd home, state lives under `/tmp/dotfiles-verify-`, no new `~/dotfiles_backup_*` appeared under `REAL_HOME`, and the operator `.zshrc` symlink is unchanged.

If doctor is `UNSAFE` because of skill drift (wrong paths, leak checks), fix this skill directory and `start` a new run. If `REAL_HOME` gained a backup directory, stop and treat that as installer leakage, not a docs problem.

## Drive

`CONTROL=./.cursor/skills/verify-dotfiles/scripts/control-dotfiles`

Every mutating or preview install goes through `control-dotfiles` so `HOME` is the isolated directory. Never run `./install.sh` against the operator home from this skill.

| User action | Command |
| --- | --- |
| Preview install | `$CONTROL install --dry-run` |
| Confirm skip-deps install | `$CONTROL install --skip-deps --confirm y` |
| Abort at the prompt | `$CONTROL install --confirm n` |
| Unknown flag | `$CONTROL run --name reject-unknown -- ./install.sh --profile unknown` |
| Unsupported platform | `$CONTROL run --name reject-platform -- env DOTFILES_PLATFORM=solaris ./install.sh --dry-run` |
| Seed a regular file | `printf 'dummy zshrc\n' \| $CONTROL seed .zshrc` |
| Inspect links | `$CONTROL links` |
| Snapshot HOME | `$CONTROL snapshot --name <id>` |
| User doctor (links only) | `$CONTROL run --name doctor-links -- ./scripts/doctor.sh --skip-nvim` |
| tmux config parse | `$CONTROL tmux-parse` |
| zsh aliases | `$CONTROL zsh-check` |
| Neovim contract | `$CONTROL nvim-contract` |

`--dry-run` always installs a `curl` trap on `PATH` (outside HOME). If `install.sh` actually downloads, the trap logs the argv, exits `42`, and the drive fails. Every `run` / `install` also sets `HOMEBREW_CACHE`, `HOMEBREW_LOGS`, and `HOMEBREW_TEMP` under the run state (not HOME) so host `brew` queries cannot pollute `home-diff.txt`.

Skip-deps defaults to `DOTFILES_CI_SMOKE_INSTALL=1` so Oh My Zsh, TPM, npm, and related clones are skipped. That is a test-mode path: the transcript must show the skip lines, and the symlinks must still be created. Use `--no-ci-smoke` only when you intend network clones into the isolated HOME.

Full Homebrew/apt install is refused unless `DOTFILES_VERIFY_ALLOW_DEPS=1` and `--allow-deps`. Local verification does not take that path. CI does: `./scripts/ci-smoke-install.sh` and `.github/workflows/full-bootstrap.yml`.

Stable handles: `./install.sh`, `./install.sh --dry-run`, `./install.sh --skip-deps`, prompt `Do you want to proceed? (y/n)`, `./scripts/doctor.sh`, `./scripts/verify-nvim.sh`. Prompt strings and flags are literal.

## Evidence

Proofs go to `.cursor/skills/verify-dotfiles/evidence/<RUN_ID>/<name>/`. Each `run` / `install` writes `command.txt`, `transcript.txt`, `exit.txt`, `home-before.txt`, `home-after.txt`, `home-diff.txt`, `links.txt`, `curl.log`.

Proof standards:

- Exercise `install.sh` or the user doctor/verify scripts, not Bats internals or sourced installer functions, unless a feature file says the user-visible abort/unknown-option path is the CLI.
- Keep the action (transcript + command) and the resulting HOME tree / link status.
- For dry-run, prove no HOME mutation by empty `home-diff.txt` and an empty `curl.log`. Do not trust the banner `Running in dry-run mode` alone.
- For skip-deps CI smoke, prove both the skip lines and the created symlinks (`OK` lines from `links`).
- Cleanup must not delete this evidence directory.

## Cleanup

```bash
./.cursor/skills/verify-dotfiles/scripts/control-dotfiles cleanup
```

Kills the private tmux server `dotfiles-verify-<id>` if present, then `rm -rf /tmp/dotfiles-verify-<id>`. Refuses to delete any other path. After a failed drive, run cleanup (or at least doctor) before another attempt; start a new run if the isolated HOME is dirty in a way the next recipe does not account for.

## Helpers

`scripts/control-dotfiles` is executable. Invoke it from the repo root as shown above. `control-dotfiles start|doctor|install|run|seed|snapshot|links|tmux-parse|zsh-check|nvim-contract|cleanup`. `control-dotfiles` with no args prints usage.
