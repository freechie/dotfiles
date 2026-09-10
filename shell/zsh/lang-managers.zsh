export NVM_DIR="$HOME/.nvm"
function load_nvm() {
    for cmd in nvm node npm npx yarn pnpm; do unset -f $cmd 2>/dev/null; done
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}

for cmd in nvm node npm npx yarn pnpm; do
    if ! alias $cmd >/dev/null 2>&1 && ! (( $+functions[$cmd] )); then
        eval "$cmd() { load_nvm; $cmd \"\$@\"; }"
    fi
done

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
load_pyenv() {
    unset -f pyenv python python3 pip pip3 2>/dev/null
    if command -v pyenv >/dev/null 2>&1; then
        eval "$(pyenv init -)"
    fi
}

if ! alias pyenv >/dev/null 2>&1 && ! (( $+functions[pyenv] )); then
    pyenv() {
        load_pyenv
        pyenv "$@"
    }
fi

for cmd in python python3 pip pip3; do
    if ! alias $cmd >/dev/null 2>&1 && ! (( $+functions[$cmd] )); then
        eval "$cmd() {
            if [[ -n \${CONDA_PREFIX:-} ]]; then
                command $cmd \"\$@\"
            else
                load_pyenv
                $cmd \"\$@\"
            fi
        }"
    fi
done

load_conda() {
    unset -f conda 2>/dev/null
    local conda_root="${CONDA_ROOT:-$HOME/anaconda3}"
    local conda_setup
    # conda.sh defines the same conda() as `conda shell.zsh hook` without a Python spawn.
    if [[ -f "$conda_root/etc/profile.d/conda.sh" ]]; then
        . "$conda_root/etc/profile.d/conda.sh"
    else
        conda_setup="$("$conda_root/bin/conda" 'shell.zsh' 'hook' 2>/dev/null)"
        if [ $? -eq 0 ]; then
            eval "$conda_setup"
        else
            export PATH="$conda_root/bin:$PATH"
        fi
        unset conda_setup
    fi
}

if ! alias conda >/dev/null 2>&1 && ! (( $+functions[conda] )); then
    conda() {
        load_conda
        conda "$@"
    }
fi

load_rbenv() {
    unset -f rbenv ruby gem bundle bundler irb 2>/dev/null
    if command -v rbenv >/dev/null 2>&1; then
        eval "$(rbenv init - zsh)"
    fi
}

for cmd in rbenv ruby gem bundle bundler irb; do
    if ! alias $cmd >/dev/null 2>&1 && ! (( $+functions[$cmd] )); then
        eval "$cmd() { load_rbenv; $cmd \"\$@\"; }"
    fi
done

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

if command -v zoxide >/dev/null 2>&1; then
    dotfiles_source_eval_cache zoxide "$(whence -p zoxide)" zoxide init zsh
fi

load_juliaup_completions() {
    unset -f juliaup
    local comps="${JULIAUP_COMPLETIONS:-$HOME/.julia/juliaup/completions/zsh.zsh}"
    [[ -r "$comps" ]] && source "$comps"
}

if ! alias juliaup >/dev/null 2>&1 && ! (( $+functions[juliaup] )); then
    if [[ -r "${JULIAUP_COMPLETIONS:-$HOME/.julia/juliaup/completions/zsh.zsh}" ]]; then
        juliaup() {
            load_juliaup_completions
            command juliaup "$@"
        }
    fi
fi
