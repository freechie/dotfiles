# Backup existing files

When a tracked path is a regular file, confirm-yes install moves it into `~/dotfiles_backup_<timestamp>/` and then creates the symlink. Existing symlinks are replaced without copying them into that backup.

## Sub-features

- `backup-regular` moves a real `~/.zshrc` into the backup directory and replaces it with the clone symlink.
- `backup-config-file` does the same for `~/.config/starship.toml`.
- `backup-skip-symlink` does not copy an existing `~/.zshrc` symlink into the backup directory.

## How to get to it (user POV)

- Have a regular file at `~/.zshrc` or `~/.config/starship.toml`, run `./install.sh --skip-deps`, answer `y`.
- Have a symlink already at `~/.zshrc`, run the same command.

## Driving it with control-dotfiles

Preconditions:

- `control-dotfiles doctor` prints `SAFE`.
- Isolated HOME is empty of the target path except for the seeded file.

- **Seed regular files.** Run `printf 'dummy zshrc\n' | ./.cursor/skills/verify-dotfiles/scripts/control-dotfiles seed .zshrc` and `printf 'dummy starship config\n' | ./.cursor/skills/verify-dotfiles/scripts/control-dotfiles seed .config/starship.toml`. Isolated HOME now has regular files `.zshrc` (`dummy zshrc`) and `.config/starship.toml` (`dummy starship config`).
- **Install.** Run `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles install --skip-deps --confirm y --name backup-files`. Exit code `0`. Transcript contains `Backing up existing .zshrc in home directory` and `Backing up existing starship.toml in ~/.config directory`.
- **Backup contents.** Isolated HOME has a `dotfiles_backup_*` directory containing `.zshrc` whose contents are still `dummy zshrc` and `starship.toml` (not `.config/starship.toml`) whose contents are still `dummy starship config`. `control-dotfiles links` reports `OK` for `platforms/<macos|ubuntu>/.zshrc` and `platforms/<macos|ubuntu>/starship.toml`.
- **Seed symlink.** On a fresh `start`, run `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles run --name seed-zshrc-symlink -- bash -c 'ln -s /dev/null "$HOME/.zshrc"'`. Then `./.cursor/skills/verify-dotfiles/scripts/control-dotfiles install --skip-deps --confirm y --name backup-skip-symlink`. Exit code `0`. No backup file `.zshrc` exists under `dotfiles_backup_*`. `.zshrc` is now the clone symlink.
- **Proof.** Keep the backup file copy in evidence (`snapshot --name backup-files` plus the transcript). Operator `REAL_HOME` still has no new `dotfiles_backup_*` (`doctor` still `SAFE`).

## Gotchas

- Backup directory is always created (`mkdir -p`) even when nothing is moved. An empty `dotfiles_backup_*` is not proof of a backup.
- Assert the backed-up file contents, not only that a backup directory exists.
- Do not prove this against operator HOME. `doctor` failing the real-backup leak check means the drive escaped isolation.
- Starship lives at `.config/starship.toml`; the backup file is stored as `starship.toml` in the backup directory, not under a `.config` subdirectory.
