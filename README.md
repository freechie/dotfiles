# Dotfiles

[![Tests](https://github.com/freechie/dotfiles/actions/workflows/test.yml/badge.svg)](https://github.com/freechie/dotfiles/actions/workflows/test.yml)
[![Full bootstrap](https://github.com/freechie/dotfiles/actions/workflows/full-bootstrap.yml/badge.svg)](https://github.com/freechie/dotfiles/actions/workflows/full-bootstrap.yml)
[![macOS](https://img.shields.io/badge/macOS-supported-000000?logo=apple&logoColor=white)](https://support.apple.com/guide/mac-help/welcome/mac)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-supported-E95420?logo=ubuntu&logoColor=white)](https://documentation.ubuntu.com/)
[![Windows](https://img.shields.io/badge/Windows-supported-0078D4?logo=windows&logoColor=white)](https://learn.microsoft.com/windows/)

Terminal-focused dotfiles for macOS, Ubuntu/Linux, and Windows PowerShell.
Includes Zsh, Bash, tmux, Neovim, Spacemacs, Ghostty, Starship, Git config,
installer scripts, and CI checks.

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

Windows uses PowerShell 7, not `install.sh`:

```powershell
git clone https://github.com/freechie/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles
./install.ps1
./install.ps1 -DryRun
./install.ps1 -SkipDeps
```

`install.ps1` links Neovim, Starship, Spacemacs, and the PowerShell profile.
It installs the Windows editor and CLI packages with winget. Zsh, tmux, and
Ghostty are left for macOS and Ubuntu. `.gitconfig` is not linked because it
turns on commit signing with a macOS key path.

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
- Windows: `./install.ps1`. See [Windows](#windows).

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

## Windows

PowerShell 7 is the shell. `platforms/windows/Microsoft.PowerShell_profile.ps1`
is linked to the PowerShell 7 profile. It sets `HOME` when that variable is
empty, prepends Neovim and Emacs to `PATH`, and sets `EDITOR` to `nvim`.
Starship and zoxide initialize when those commands exist.

`./install.ps1` installs Neovim, Emacs, Starship, ripgrep, fd, fzf, zoxide,
eza, lazygit, and Node with winget, then links:

- `%LOCALAPPDATA%\nvim` to `nvim/`
- `~/.spacemacs`, `~/.spacemacs.d/local.el`, `darwin.el`, and `windows.el`
- `~/.config/starship.toml`
- the PowerShell profile

`.gitconfig` stays unlinked. Its commit signing key is a macOS path. Zsh,
tmux, and Ghostty stay on macOS and Ubuntu.

Neovim parser builds use MinGW. Set the user `CC` variable to the full path of
`x86_64-w64-mingw32-gcc.exe` from the WinLibs package. Neovim must find
`tree-sitter.exe` on `PATH`; the npm `.cmd` shim is not executable from the
editor. Windows hooks live in `nvim/lua/core/platform/windows.lua`.

Spacemacs uses Source Code Pro. macOS keeps 17pt in `emacs/.spacemacs`.
Windows uses 13pt from `emacs/windows.el`. Icons use FiraCode Nerd Font Mono.
From an elevated PowerShell:

```powershell
choco install SourceCodePro nerd-fonts-FiraCode -y
```

`emacs/.spacemacs` is shared. `emacs/local.el` loads `emacs/darwin.el` or
`emacs/windows.el`. The macOS file keeps the Org paths under `/Users/what`
and lets `auto-dark` pick the Mac detector. The Windows file sets the smaller
font, package quickstart, the Org reinstall guard, frame resize, and
`auto-dark` with the Windows registry. Quit Emacs and start it again after
changing those. `SPC q R` does not reread early frame setup.

`~/.emacs.d` is the Spacemacs `develop` clone. `emacs/windows-early-init.el`
is appended to its `early-init.el` by `./install.ps1`, because Emacs reads
that file before `.spacemacs` and a Spacemacs update can replace it. The
block is skipped on macOS.

Starship prints the short hostname from `[custom.hostwin]` in `starship.toml`.
`[custom.host]` is Unix-only.

## What Is Managed

- Shell: `.zshrc`, `.bash_profile`, shared modules in `shell/`
- tmux: `.tmux.conf`, platform overrides in `tmux/`
- Neovim: `nvim/`, plugin pins in `nvim/lazy-lock.json`
- Spacemacs: `emacs/.spacemacs` (linked to `~/.spacemacs`). `emacs/local.el` loads `emacs/darwin.el` on macOS and `emacs/windows.el` on Windows. `~/.emacs.d` is a clone of develop. `~/.spacemacs.env` stays machine-local.
- Ghostty: platform configs in `ghostty/`
- Rectangle Pro: `RectangleProConfig.json`. On macOS, the installer copies it to `~/Library/Application Support/Rectangle Pro/RectangleProConfig.json`. Rectangle Pro imports that copy on its next launch and then renames it.
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

## GitHub Pages

`docs/` is the command cheat sheet. Publish GitHub Pages from the `main`
branch, folder `/docs`:

```text
https://freechie.github.io/dotfiles/
```

That replaces the separate `devtools` site. GitHub Pages uses the repository
name in the URL, so `freechie.github.io/devtools/` cannot be served from this
repo.

## License

MIT
