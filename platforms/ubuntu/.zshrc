ZSHRC_DIR="${${(%):-%N}:P:h}"
export DOTFILES_ROOT="${ZSHRC_DIR:h:h}"
export DOTFILES_PLATFORM="linux"

source "$DOTFILES_ROOT/shell/zsh/entrypoint.zsh"
export GH_BROWSER=wslview

# fnm
FNM_PATH="/home/what/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/home/what/.juliaup/bin' $path)
export PATH
# Tab completion for juliaup and julia channel selection
[ -f "/home/what/.julia/juliaup/completions/zsh.zsh" ] && source "/home/what/.julia/juliaup/completions/zsh.zsh"

# <<< juliaup initialize <<<
