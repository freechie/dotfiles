# Dotfiles

[![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white)](https://support.apple.com/guide/mac-help/welcome/mac)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?logo=ubuntu&logoColor=white)](https://documentation.ubuntu.com/)
[![Zsh](https://img.shields.io/badge/Zsh-F15A24?logo=gnubash&logoColor=white)](https://zsh.sourceforge.io/Doc/)
[![Bash](https://img.shields.io/badge/Bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/manual/)
[![tmux](https://img.shields.io/badge/tmux-1BB91F?logo=tmux&logoColor=white)](https://github.com/tmux/tmux/wiki)
[![Neovim](https://img.shields.io/badge/Neovim-57A143?logo=neovim&logoColor=white)](https://neovim.io/doc/)
[![Spacemacs](https://img.shields.io/badge/Spacemacs-9266CC?logo=emacs&logoColor=white)](https://www.spacemacs.org/doc/DOCUMENTATION.html)
[![Emacs](https://img.shields.io/badge/Emacs-7F5AB6?logo=gnuemacs&logoColor=white)](https://www.gnu.org/software/emacs/manual/)
[![Ghostty](https://img.shields.io/badge/Ghostty-2E2E2E?logo=ghost&logoColor=white)](https://ghostty.org/docs)
[![Starship](https://img.shields.io/badge/Starship-DD0B64?logo=starship&logoColor=white)](https://starship.rs/guide/)
[![Git](https://img.shields.io/badge/Git-F05032?logo=git&logoColor=white)](https://git-scm.com/doc)
[![Homebrew](https://img.shields.io/badge/Homebrew-FBB040?logo=homebrew&logoColor=black)](https://docs.brew.sh/)
[![apt](https://img.shields.io/badge/apt-A80030?logo=debian&logoColor=white)](https://manpages.ubuntu.com/manpages/noble/en/man8/apt.8.html)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=githubactions&logoColor=white)](https://docs.github.com/en/actions)
[![Bats](https://img.shields.io/badge/Bats-1D4ED8)](https://bats-core.readthedocs.io/en/stable/)
[![fzf](https://img.shields.io/badge/fzf-000000)](https://junegunn.github.io/fzf/)
[![ripgrep](https://img.shields.io/badge/ripgrep-A8B9CC)](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)
[![fd](https://img.shields.io/badge/fd-0F766E)](https://github.com/sharkdp/fd#how-to-use)
[![eza](https://img.shields.io/badge/eza-87FFAF)](https://github.com/eza-community/eza/blob/main/man/eza.1.md)
[![zoxide](https://img.shields.io/badge/zoxide-5B21B6)](https://github.com/ajeetdsouza/zoxide)
[![Lazy.nvim](https://img.shields.io/badge/Lazy.nvim-457B9D)](https://lazy.folke.io/)
[![Mason](https://img.shields.io/badge/Mason-1D4ED8)](https://github.com/mason-org/mason.nvim)
[![Lua](https://img.shields.io/badge/Lua-2C2D72?logo=lua&logoColor=white)](https://www.lua.org/manual/5.4/)
[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)](https://docs.python.org/3/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?logo=nodedotjs&logoColor=white)](https://nodejs.org/docs/latest/api/)
[![Ruby](https://img.shields.io/badge/Ruby-CC342D?logo=ruby&logoColor=white)](https://docs.ruby-lang.org/en/)
[![Go](https://img.shields.io/badge/Go-00ADD8?logo=go&logoColor=white)](https://go.dev/doc/)
[![PHP](https://img.shields.io/badge/PHP-777BB4?logo=php&logoColor=white)](https://www.php.net/docs.php)
[![Rust](https://img.shields.io/badge/Rust-000000?logo=rust&logoColor=white)](https://doc.rust-lang.org/book/)
[![Java](https://img.shields.io/badge/Java-ED8B00?logo=openjdk&logoColor=white)](https://docs.oracle.com/en/java/)
[![LazyGit](https://img.shields.io/badge/LazyGit-0A60C8)](https://github.com/jesseduffield/lazygit)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/)

Terminal-focused dotfiles for macOS and Ubuntu/Linux. Includes Zsh, Bash,
tmux, Neovim, Ghostty, Starship, Git config, installer scripts, and CI checks.

## Install

```bash
git clone https://github.com/freechie/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Useful modes:

```bash
./install.sh --dry-run    # show planned changes only
./install.sh --skip-deps  # skip Homebrew, apt, and the Linux Neovim install
```

The installer backs up replaced files to `~/dotfiles_backup_<timestamp>` and
then creates symlinks for the tracked configs. It validates the platform and
every link source before writing to the home directory. The links are activated
before package downloads, so a package-manager failure does not discard the
working configuration.

Standalone downloads retry transient network errors and require a matching
SHA256 checksum. Independent setup steps such as shell plugins and Neovim host
providers continue after one fails, then appear together in the final error
report. Fix the reported cause and rerun the installer. Existing links remain
in place.

`--skip-deps` skips system package setup but still installs optional shell and
editor helpers when their package managers are already available.

## Platforms

- macOS: installs core Homebrew dependencies from `Brewfile`.
- Ubuntu/Linux: installs core packages with `apt` and a pinned upstream Neovim
  release into `~/.local`.

Linux support is Ubuntu/Debian-first. Other distributions should install
equivalent packages manually, then use `./install.sh --skip-deps`.

Optional macOS workstation profiles are tracked separately and installed
manually when needed:

```bash
brew bundle --file=Brewfile.terminal-gui
brew bundle --file=Brewfile.vscode
brew bundle --file=Brewfile.heavy
```

The personal macOS profile includes a third-party tap and requires explicit
trust before installing `dark-notify`. It also installs GUI Emacs via
`emacs-plus@31`. Do not put emacs-plus in the core `Brewfile`; the formula
compiles from source.

```bash
brew tap cormacrelf/tap
brew trust --formula cormacrelf/tap/dark-notify
brew tap d12frosted/emacs-plus
brew bundle --file=Brewfile.personal-macos
```

## What Is Managed

- Shell: `.zshrc`, `.bash_profile`, shared modules in `shell/`
- tmux: `.tmux.conf`, platform overrides in `tmux/`
- Neovim: `nvim/`, plugin pins in `nvim/lazy-lock.json`
- Spacemacs: `emacs/.spacemacs` (linked to `~/.spacemacs`; `~/.emacs.d` is a clone of develop)
- Ghostty: platform configs in `ghostty/`
- Starship: `starship.toml` (platform paths under `platforms/` are symlinks to it)
- Git: `.gitconfig`, `.gitignore_global`

`~/.emacs.d` is a clone of Spacemacs `develop`, not a symlink into this repo.
On macOS, Spotlight ignores `Emacs.app` symlinks (`brew linkapps` is gone).
When `emacs-plus@31` is installed and `./install.sh` runs against your real
home, it copies `Emacs.app` into `/Applications` and unlinks Homebrew core
`emacs` so `emacs` on PATH is the Cocoa build.

`config/toolchain.sh` is the source of truth for package lists, minimum tool
versions, pinned installer URLs, and SHA256 checksums.

## Verify

```bash
./scripts/doctor.sh
./scripts/verify-nvim.sh
./test.sh
```

`./test.sh` runs Bats coverage for installer behavior, syntax checks, repo
consistency, bootstrap smoke tests, and CI smoke flows.

## CI

GitHub Actions runs tests on Ubuntu and macOS, runs Gitleaks, and performs
cross-platform smoke installs. A separate full-bootstrap workflow covers the
default dependency install path.

Actions are pinned to immutable SHAs. Refresh an action by resolving the
desired tag with `git ls-remote`, updating the SHA, and keeping the inline
version comment accurate.

## Updates

Refresh Homebrew state:

```bash
bbu
```

`bbu` writes an ignored `Brewfile.snapshot`. Review it and manually move
intentional package changes into the appropriate Brewfile profile.

Refresh Neovim plugins through Lazy, then commit the resulting
`nvim/lazy-lock.json` changes when the pin updates are intentional.

Refresh pinned bootstrap artifacts by updating the version/URL and matching
SHA256 together in `config/toolchain.sh`.

## Key Commands

- `ta`: attach to or create a tmux session
- `Prefix + I`: install tmux plugins
- `Prefix + r`: reload tmux config
- `<Space>`: Neovim leader key
- `<Leader>ff`: find files
- `<Leader>fg`: live grep
- `<Leader>e`: toggle file explorer
- `<Leader>gg`: open LazyGit
- `<Leader>cf`: format current buffer
- `SPC`: Spacemacs leader key
- `update`: platform-specific system update helper
- `bbu`: write ignored Homebrew snapshot

## License

MIT
