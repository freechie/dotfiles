## Learned User Preferences

- John commits and pushes himself. Provide a commit message from the diff and stop. Open a PR only when he asks in that message.
- Commit authorship stays John, with no co-author trailer and no Cursor or agent attribution.
- Leave the macOS and Ubuntu Starship prompt as configured during unrelated work: a 3-character hostname, the current directory only, a trailing slash, and `…/` when the path is truncated.
- Commit messages open in Spacemacs through `emacsclient`, including from Rex, with git commit mode loaded. SSH signing stays on and should not prompt for a passphrase on every commit.
- macOS Spacemacs follows the system appearance through `auto-dark` in `emacs/darwin.el`, including a Rex tty via `osascript`. Windows theme, font, and `winreg` detection stay in `emacs/windows.el`.
- Open Spacemacs in the current terminal with `e`, not a new Emacs.app window. Keep the home buffer centered in a wide pane, and keep its buttons clickable from Rex.
- Neovim inserts a completion only after it is selected. Dismissing a suggestion stays in insert mode.
- Zsh tab-completes directories without requiring `cd`.
- macOS `update` asks for the account password once and reuses it for later Homebrew `sudo`. Touch ID can cover `sudo`, but `softwareupdate` and the Apple Silicon volume-owner check still need that password.
- A codebase review looks for errors, bugs, and redundancy. Include agent-skill tracking only when he asks for it.
- `docs/index.html` tracks the commands he actually uses, with Spacemacs ahead of tmux. README technology badges link to each project's documentation.
- Rex reuses some macOS Ghostty keys, not the whole Ghostty config.

## Learned Workspace Facts

- These are John's dotfiles for macOS, Ubuntu, and Windows (`github.com/freechie/dotfiles`). `main` rejects force-pushes. macOS and Ubuntu install with `./install.sh`; Windows uses `./install.ps1`. The installer backs up replaced files, then creates symlinks.
- `config/toolchain.sh` is the source of truth for package lists, minimum versions, pinned URLs, and SHA256 checksums. `emacs-plus@31` stays in `Brewfile.personal-macos`. `bbu` writes the ignored `Brewfile.snapshot` only.
- Spacemacs config is `emacs/.spacemacs`, linked to `~/.spacemacs`. `emacs/local.el` loads `emacs/darwin.el` or `emacs/windows.el`. `~/.emacs.d` is a Spacemacs `develop` clone. The shared font is Source Code Pro at 14pt; Windows overrides it to 13pt. `SPC q R` does not reread early frame setup. The `git` layer loads `git-commit` on `after-init-hook` so a daemon has the commit editor before `emacsclient` connects. Emacs aliases `xterm-rex` to `xterm-256color`. The home buffer redraws after the emacsclient frame exists, and a Rex mouse-up activates its buttons.
- `.gitconfig` sets `core.editor` to `emacsclient -nw -a ''`, SSH commit signing, and rebase pulls. The Windows installer leaves it unlinked because the signing key path is macOS-only.
- Starship uses `starship.toml` on macOS and Ubuntu. Windows uses `platforms/windows/starship.toml` (`PS`, backslash paths, `>`).
- Ghostty configs live in `ghostty/`. `rex/init.lua` binds the macOS Ghostty pane-focus keys and `install.sh` links it to `~/.config/rex/init.lua`. `install.sh` copies Ghostty's `xterm-ghostty` terminfo into `~/.terminfo` so Emacs can start there. `RectangleProConfig.json` is copied into Rectangle Pro's Application Support folder; the app imports that copy and renames it.
- `docs/` is the GitHub Pages cheat sheet, published from `main` `/docs` at `https://freechie.github.io/dotfiles/`. The old `devtools` Pages URL cannot be served from this repo.
- Verification is `./scripts/doctor.sh`, `./scripts/verify-nvim.sh`, `./test.sh` (Bats), and `.agents/skills/verify-dotfiles`. GitHub Actions runs Ubuntu and macOS tests, Gitleaks, and full-bootstrap, with actions pinned to SHAs. `graphify-out/` is generated and gitignored.
- Shell config is `.zshrc`, `.bash_profile`, and `shell/`. `EDITOR` and `VISUAL` are `emacsclient -nw -a ''`. `e` in `shell/zsh/aliases.zsh` and `shell/bash/common.bash` runs that client. macOS `update` is in `shell/zsh/platform/macos.zsh` and `shell/bash/macos.bash`.
