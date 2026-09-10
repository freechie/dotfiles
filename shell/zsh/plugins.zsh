source "$DOTFILES_ROOT/shell/zsh/plugins/common.zsh"

case "${DOTFILES_PLATFORM:-}" in
  macos)
    source "$DOTFILES_ROOT/shell/zsh/plugins/macos.zsh"
    ;;
  linux)
    source "$DOTFILES_ROOT/shell/zsh/plugins/linux.zsh"
    ;;
esac

# Load the plugin files without oh-my-zsh.sh (that script runs git + compaudit on
# every shell).
_dotfiles_omz_plugin_dir() {
  if [[ -d "$ZSH/custom/plugins/$1" ]]; then
    print -r -- "$ZSH/custom/plugins/$1"
  elif [[ -d "$ZSH/plugins/$1" ]]; then
    print -r -- "$ZSH/plugins/$1"
  fi
}

_dotfiles_source_plugin_file() {
  source "$1"
}

for _dotfiles_plugin in $plugins; do
  _dotfiles_plugin_dir="$(_dotfiles_omz_plugin_dir "$_dotfiles_plugin")"
  [[ -n "$_dotfiles_plugin_dir" ]] && fpath=("$_dotfiles_plugin_dir" $fpath)
done

mkdir -p "$ZSH_CACHE_DIR"
_dotfiles_zcompdump="$ZSH_CACHE_DIR/zcompdump-${ZSH_VERSION}"
autoload -Uz compinit
if [[ "${ZSH_DISABLE_COMPFIX:-}" == true ]]; then
  compinit -C -d "$_dotfiles_zcompdump"
elif [[ -s "$_dotfiles_zcompdump" ]]; then
  compinit -C -d "$_dotfiles_zcompdump"
else
  compinit -i -d "$_dotfiles_zcompdump"
fi
zmodload -i zsh/complist

# macos plugin calls open_command from this lib file.
if [[ -r "$ZSH/lib/functions.zsh" ]]; then
  _dotfiles_source_plugin_file "$ZSH/lib/functions.zsh"
fi

for _dotfiles_plugin in $plugins; do
  _dotfiles_plugin_dir="$(_dotfiles_omz_plugin_dir "$_dotfiles_plugin")"
  if [[ -r "$_dotfiles_plugin_dir/${_dotfiles_plugin}.plugin.zsh" ]]; then
    # Plugin files use `return`; source via a function so they cannot skip later plugins.
    _dotfiles_source_plugin_file "$_dotfiles_plugin_dir/${_dotfiles_plugin}.plugin.zsh"
  fi
done
unset -f _dotfiles_omz_plugin_dir _dotfiles_source_plugin_file
unset _dotfiles_plugin _dotfiles_plugin_dir _dotfiles_zcompdump
