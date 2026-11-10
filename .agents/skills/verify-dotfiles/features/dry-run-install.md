# Dry-run install

Dry-run install shows the platform plan and every write or download as a `DRY RUN:` line, then exits successfully without changing the isolated HOME or calling `curl`.

## Sub-features

- `dry-run-banner` prints the platform, planned steps, and `Running in dry-run mode (no changes will be made).`
- `dry-run-links` prints `DRY RUN: ln -snf` for zsh, tmux, nvim, starship, git, Spacemacs, and Ghostty.
- `dry-run-no-fs` leaves the isolated HOME tree unchanged.
- `dry-run-no-curl` does not invoke `curl` even when Homebrew is missing from the story.

## How to get to it (user POV)

- Run `./install.sh --dry-run` from the clone.
- Run `./install.sh -n` (same flag).

## Driving it with control-dotfiles

Preconditions:

- `control-dotfiles doctor` prints `SAFE`.
- Isolated HOME contains only the `.config` directory created at `start`.

- **Preview.** Run `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles install --dry-run`. Exit code `0`. Transcript contains `Running in dry-run mode (no changes will be made).` and `Detected platform:` matching `PLATFORM=` from `start`.
- **Planned links.** Same transcript contains `DRY RUN: ln -snf` lines whose destinations sit under the isolated `HOME=` path, including `.zshrc`, `.tmux.conf`, `.config/nvim`, `.config/starship.toml`, `.gitconfig`, `.spacemacs`, and the platform Ghostty config.
- **No HOME mutation.** `evidence/<RUN_ID>/dry-run-install/home-diff.txt` is empty. Isolated HOME still has no `.zshrc` and no `dotfiles_backup_*`.
- **No download.** `evidence/<RUN_ID>/dry-run-install/curl.log` is empty. Transcript may contain `DRY RUN: download` and `DRY RUN: brew bundle` lines; those must not be paired with a curl-trap error.
- **Proof.** Keep `transcript.txt`, `exit.txt`, empty `home-diff.txt`, and empty `curl.log`.

## Gotchas

- Host `PATH` still answers `command -v brew`, `hunk`, and `tree-sitter`. The transcript may say those tools are already installed. That is not proof that dry-run ran them.
- Do not assert a Homebrew download line on macOS when Homebrew is already on `PATH`; assert the `DRY RUN: brew bundle install --file=` line instead.
- Dry-run still runs `brew --prefix` / `brew list` in emacs-plus PATH logic. Those queries would write `~/Library/Caches/Homebrew`. `control-dotfiles` sets `HOMEBREW_CACHE`, `HOMEBREW_LOGS`, and `HOMEBREW_TEMP` under the run state, outside isolated HOME, so `home-diff.txt` stays empty. Homebrew cache inside HOME means the harness env leaked.
- The curl trap lives under `/tmp/dotfiles-verify-<id>/bin`, not inside HOME. A new `HOME/bin/curl` would be an installer bug.
- `-n` is the same switch as `--dry-run`. Driving one of them is enough for this feature; say so if you only ran one.
