# Post-install startup

After a skip-deps install, doctor can check the new links, zsh exposes `gs`, tmux can parse `~/.tmux.conf` on a private socket, and `scripts/verify-nvim.sh` can load the linked Neovim config.

## Sub-features

- `startup-doctor-links` runs `./scripts/doctor.sh --skip-nvim` against isolated HOME and passes the symlink checks.
- `startup-zsh-gs` sources `~/.zshrc` and shows `gs='git status -sb'`.
- `startup-tmux-parse` loads `~/.tmux.conf` and shows prefix `C-a`.
- `startup-nvim-contract` runs `scripts/verify-nvim.sh` with `DOTFILES_CI_SMOKE_NVIM=1`.

## How to get to it (user POV)

- After install, run `./scripts/doctor.sh`.
- Open a new zsh and use aliases such as `gs`.
- Start tmux (`ta` or `tmux`).
- Start Neovim with this repo's `nvim/` config.

## Driving it with control-dotfiles

Preconditions:

- Same `RUN_ID` already completed `install --skip-deps --confirm y` with all `OK` links.
- `control-dotfiles doctor` prints `SAFE`.

- **Doctor links.** Run `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles run --name doctor-links -- ./scripts/doctor.sh --skip-nvim`. Transcript contains `PASS .zshrc points to expected dotfiles target` and `PASS .config/nvim points to expected dotfiles target`. Tool checks use host `PATH` and may `PASS` or `FAIL` independently; this feature is proven by the `PASS` link lines, not by brew/nvim versions.
- **zsh.** Run `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles zsh-check`. Exit code `0`. Transcript contains `gs='git status -sb'` and `platform:` matching the run platform.
- **tmux.** Run `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles tmux-parse`. Exit code `0`. Transcript contains `C-a`. The server uses socket `dotfiles-verify-<RUN_ID>` and `TMUX_TMPDIR` under the run state, not the operator tmux.
- **Neovim contract.** Run `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles nvim-contract`. Exit code `0`. Transcript contains `PASS nvim headless startup` and the declared LSP/Mason/treesitter tokens. `DOTFILES_CI_SMOKE_NVIM=1` must be in effect so Lazy does not rewrite `nvim/lazy-lock.json`.
- **Proof.** Keep `doctor-links/transcript.txt`, `zsh-check/transcript.txt`, `tmux-parse/transcript.txt`, and `nvim-contract/transcript.txt`. After `cleanup`, those files still exist. `git status` does not show a modified `nvim/lazy-lock.json`.

## Gotchas

- `./scripts/doctor.sh` without `--skip-nvim` also runs the Neovim contract. Isolation of `HOME` comes from `control-dotfiles run`, not from `doctor.sh` itself. Prefer `--skip-nvim` plus `nvim-contract` so failures separate.
- zsh check does not need Oh My Zsh; `oh-my-zsh.sh` is sourced only if present. CI-smoke skip-deps will not install it.
- `platforms/macos/.zshrc` may contain machine-local conda/juliaup blocks. They are not the proof; `gs` and `platform:` are.
- If tmux prints `Operation not permitted`, the sandbox blocked the socket. Report `verified-unreachable` with that message; do not kill the operator tmux by name.
- `nvim-contract` points `XDG_DATA_HOME` at the run state. First load may still clone `lazy.nvim` if it is missing. That clone must stay out of the operator `~/.local/share/nvim`.
