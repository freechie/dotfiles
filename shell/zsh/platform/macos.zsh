(( $+aliases[update] )) && unalias update

function update {
  # One password covers softwareupdate and later Homebrew sudo. Homebrew
  # runs sudo with stdin closed, so a normal sudo ticket is not reused.
  local password askpass secret
  read -rs "password?Password: " || return 1
  print
  secret="$(mktemp "${TMPDIR:-/tmp}/dotfiles-sudo-secret.XXXXXX")" || return 1
  askpass="$(mktemp "${TMPDIR:-/tmp}/dotfiles-sudo-askpass.XXXXXX")" || return 1
  chmod 600 "$secret" || return 1
  printf '%s\n' "$password" > "$secret" || return 1
  printf '%s\n' '#!/bin/sh' "cat '$secret'" > "$askpass" || return 1
  chmod 700 "$askpass" || return 1
  (
    export SUDO_ASKPASS="$askpass"
    trap 'rm -f "$secret" "$askpass"; unset SUDO_ASKPASS' EXIT INT TERM
    sudo -A -v || exit 1
    printf '%s\n' "$password" \
      | sudo -A -p '' softwareupdate -i -a --agree-to-license --user "$USER" --stdinpass
    unset password
    if command -v brew >/dev/null 2>&1; then
      brew update && HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade && brew cleanup
    fi
    if command -v omz >/dev/null 2>&1; then
      omz update
    fi
    echo "Updates complete."
  )
}

alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'
