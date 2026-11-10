# Abort and reject

The installer leaves HOME untouched when the user answers `n`, when a flag is unknown, or when the platform is unsupported.

## Sub-features

- `abort-no` prints `Installation aborted.` after `n` and creates no symlinks.
- `reject-unknown` exits on an unknown option and names that option.
- `reject-platform` exits on an unsupported `DOTFILES_PLATFORM` before linking.

## How to get to it (user POV)

- Run `./install.sh` and answer `n` at `Do you want to proceed? (y/n)`.
- Run `./install.sh --profile unknown` (or any unknown flag).
- Run the installer on an unsupported platform.

## Driving it with control-dotfiles

Preconditions:

- `control-dotfiles doctor` prints `SAFE`.
- Isolated HOME has no `.zshrc`.

- **Abort.** Run `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles install --confirm n`. Exit code `1`. Transcript contains `Installation aborted.` `home-diff.txt` is empty. `.zshrc` is not a symlink.
- **Unknown option.** Run `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles run --name reject-unknown -- ./install.sh --profile unknown --dry-run`. Exit code `1`. Transcript contains `Unknown option: --profile`. Isolated HOME still has no `.zshrc`.
- **Unsupported platform.** Run `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles run --name reject-platform -- env DOTFILES_PLATFORM=solaris ./install.sh --dry-run`. Exit code `1`. Transcript contains `Unsupported platform: solaris`. Isolated HOME still has no `.zshrc` and no `dotfiles_backup_*`.
- **Proof.** Keep each `transcript.txt` and `exit.txt`, plus empty or unchanged `home-diff.txt` for abort.

## Gotchas

- `control-dotfiles` itself also exits `1` when the installer does. Evidence is still written; do not treat that helper status as a harness crash.
- `--confirm n` is the abort path and does not require `--skip-deps`. A full brew install is not started.
- Unknown-option parsing happens before the prompt. `--dry-run` on that command does not make the unknown flag succeed.
- `DOTFILES_PLATFORM` is the test override. Users do not set it; the observable failure is still the `Unsupported platform:` message.
