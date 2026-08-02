ZSHRC_DIR="${${(%):-%N}:P:h}"
export DOTFILES_ROOT="${ZSHRC_DIR:h:h}"
export DOTFILES_PLATFORM="macos"

source "$DOTFILES_ROOT/shell/zsh/entrypoint.zsh"

# fnm
FNM_PATH="/opt/homebrew/opt/fnm/bin"
if [ -d "$FNM_PATH" ]; then
  eval "$(fnm env --shell zsh)"
fi

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/Users/what/.juliaup/bin' $path)
export PATH
# Tab completion for juliaup and julia channel selection
[ -f "/Users/what/.julia/juliaup/completions/zsh.zsh" ] && source "/Users/what/.julia/juliaup/completions/zsh.zsh"

# <<< juliaup initialize <<<

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/what/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/what/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/what/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/what/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

