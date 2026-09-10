export EDITOR='nvim'
export VISUAL='nvim'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export HISTSIZE=50000
export SAVEHIST=50000

# Source stdout of a command, rebuilding when the binary is newer than the cache.
dotfiles_source_eval_cache() {
    local name="$1"
    local bin="$2"
    shift 2
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
    local cache="$cache_dir/${name}.zsh"

    mkdir -p "$cache_dir" || return 1
    if [[ ! -s "$cache" || ( -n "$bin" && -e "$bin" && "$cache" -ot "$bin" ) ]]; then
        if ! "$@" >| "$cache"; then
            rm -f "$cache"
            return 1
        fi
    fi
    source "$cache"
}

if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  bat() { command batcat "$@"; }
fi

if command -v bat >/dev/null 2>&1; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
else
  unset MANPAGER
fi
