(( $+aliases[update] )) && unalias update

function update {
  local password sudo_keepalive
  # sudo and Apple Silicon's volume-owner check are separate prompts.
  # Read the password once and give that same secret to both.
  read -rs "password?Password: " || return 1
  print
  printf '%s\n%s\n' "$password" "$password" \
    | sudo -S -p '' softwareupdate -i -a --agree-to-license --user "$USER" --stdinpass
  unset password

  if sudo -n true 2>/dev/null; then
    while true; do
      sudo -n true 2>/dev/null || exit
      sleep 60
      kill -0 $$ || exit
    done &
    sudo_keepalive=$!
  fi

  if command -v brew >/dev/null 2>&1; then
    brew update && HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade && brew cleanup
  fi

  if [[ -n "${sudo_keepalive:-}" ]]; then
    kill "$sudo_keepalive" 2>/dev/null
    wait "$sudo_keepalive" 2>/dev/null
  fi

  if command -v omz >/dev/null 2>&1; then
    omz update
  fi
  echo "Updates complete."
}

alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'
