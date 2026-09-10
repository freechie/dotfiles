setopt EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
setopt AUTO_CD PUSHD_IGNORE_DUPS COMPLETE_IN_WORD ALWAYS_TO_END AUTO_MENU
unsetopt BEEP MENU_COMPLETE
zstyle ':completion:*' menu select
zstyle ':completion:*' group-names ''
# Case-insensitive + partial-word matching so `sites/dot<TAB>` completes `Sites/dotfiles`.
zstyle ':completion:*' matcher-list \
  'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
  'r:|=*' \
  'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
