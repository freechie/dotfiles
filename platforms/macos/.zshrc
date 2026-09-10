ZSHRC_DIR="${${(%):-%N}:P:h}"
export DOTFILES_ROOT="${ZSHRC_DIR:h:h}"
export DOTFILES_PLATFORM="macos"

source "$DOTFILES_ROOT/shell/zsh/entrypoint.zsh"

# fnm
FNM_PATH="/opt/homebrew/opt/fnm/bin"
if [ -d "$FNM_PATH" ]; then
  eval "$(fnm env --shell zsh)"
fi

# juliaup PATH is in shell/zsh/path/common.zsh.
# Completions lazy-load via load_juliaup_completions; do not re-run juliaup's zsh init.

# Conda is lazy-loaded by load_conda in shell/zsh/lang-managers.zsh.
# Do not re-run `conda init zsh`; it would restore a 500ms+ Python hook on every prompt.

export PATH="$HOME/.gem/ruby/4.0.0/bin:$PATH"
