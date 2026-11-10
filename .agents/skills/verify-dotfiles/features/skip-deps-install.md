# Skip-deps install

Skip-deps install is the confirm-yes path that creates platform-correct symlinks without Homebrew or apt, and can be run a second time without rewriting correct links.

## Sub-features

- `skip-deps-confirm` proceeds after `y` and prints `Skipping dependency installation (--skip-deps).`
- `skip-deps-links` creates the zsh, `.bash_profile`, tmux, nvim, starship, git, Spacemacs, and Ghostty links into the clone.
- `skip-deps-ci-smoke` skips Oh My Zsh, TPM, hunkdiff, Node/Ruby Neovim hosts, Spacemacs clone, and related extras when `DOTFILES_CI_SMOKE_INSTALL=1`.
- `skip-deps-idempotent` on a second `y` run reports links `already correctly set up`.

## How to get to it (user POV)

- Run `./install.sh --skip-deps`, then answer `y` at `Do you want to proceed? (y/n)`.
- Run that command a second time on an already-linked home.

## Driving it with control-dotfiles

Preconditions:

- `control-dotfiles doctor` prints `SAFE`.
- Isolated HOME has no `.zshrc` yet, or this recipe already created the links and you are on the idempotent step.

- **Confirm yes.** Run `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles install --skip-deps --confirm y`. Exit code `0`. Transcript contains `Skipping dependency installation (--skip-deps).` and `Dotfiles installation complete!`
- **CI smoke skips.** Same transcript contains `Skipping Oh My Zsh extras install: CI smoke mode.`, `Skipping Tmux Plugin Manager install: CI smoke mode.`, `Skipping hunkdiff install: CI smoke mode.`, `Skipping Node.js Neovim host install: CI smoke mode.`, `Skipping Ruby Neovim host install: CI smoke mode.`, and `Skipping Spacemacs clone: CI smoke mode.` Isolated HOME has no `.oh-my-zsh` and no `.tmux/plugins/tpm`.
- **Links.** Run `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles links`. Every line starts with `OK`. Keys are repo-relative: on macOS `platforms/macos/.zshrc` and `ghostty/config.macos`; on linux `platforms/ubuntu/.zshrc` and `ghostty/config.linux`; on both `nvim`, `emacs/.spacemacs`, `.tmux.conf`.
- **Idempotent second run.** Run `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles install --skip-deps --confirm y --name skip-deps-idempotent`. Exit code `0`. Transcript contains `already correctly set up`. `links` still all `OK`.
- **Proof.** Keep both transcripts, both `exit.txt` files, and `links.txt` whose lines are `OK <repo-rel> -> <abs>`.

## Gotchas

- Default skip-deps is CI smoke. That is not a full extras install. If the transcript lacks the skip lines, the drive was `--no-ci-smoke` or the env leaked.
- `--no-ci-smoke` clones Oh My Zsh and TPM into isolated HOME and needs network. Do not call that verified by the CI-smoke recipe.
- Host tools on `PATH` can still look "already installed" (hunkdiff, tree-sitter). Assert skips and links, not host versions.
- Reuse the same `RUN_ID` for the idempotent second run. A fresh `start` has no links to keep.
