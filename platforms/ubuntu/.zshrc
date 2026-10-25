ZSHRC_DIR="${${(%):-%N}:P:h}"
export DOTFILES_ROOT="${ZSHRC_DIR:h:h}"
export DOTFILES_PLATFORM="linux"

source "$DOTFILES_ROOT/shell/zsh/entrypoint.zsh"
export GH_BROWSER=wslview

# fnm (default user install location on Linux)
FNM_PATH="${FNM_PATH:-$HOME/.local/share/fnm}"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

# juliaup PATH is in shell/zsh/path/common.zsh.
# Completions lazy-load via load_juliaup_completions; do not re-run juliaup's zsh init.
