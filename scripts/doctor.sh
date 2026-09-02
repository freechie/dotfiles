#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd -P)"

# shellcheck disable=SC1091
. "$repo_root/shell/shared/platform.sh"
# shellcheck disable=SC1091
. "$repo_root/config/toolchain.sh"

export PATH="$HOME/.local/bin:$PATH"

failures=0
warnings=0
run_nvim_verify=1

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-nvim) run_nvim_verify=0 ;;
        *)
            echo "Unknown doctor option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

pass() {
    printf 'PASS %s\n' "$1"
}

warn() {
    warnings=$((warnings + 1))
    printf 'WARN %s\n' "$1"
}

fail() {
    failures=$((failures + 1))
    printf 'FAIL %s\n' "$1"
}

expected_link_target() {
    local path="$1"
    local platform_dir

    if dotfiles_is_linux; then
        platform_dir="ubuntu"
    else
        platform_dir="macos"
    fi

    case "$path" in
        ".zshrc") printf '%s\n' "$repo_root/platforms/$platform_dir/.zshrc" ;;
        ".bash_profile") printf '%s\n' "$repo_root/platforms/$platform_dir/.bash_profile" ;;
        ".tmux.conf") printf '%s\n' "$repo_root/.tmux.conf" ;;
        ".config/nvim") printf '%s\n' "$repo_root/nvim" ;;
        ".config/starship.toml") printf '%s\n' "$repo_root/platforms/$platform_dir/starship.toml" ;;
        ".spacemacs") printf '%s\n' "$repo_root/emacs/.spacemacs" ;;
        *) return 1 ;;
    esac
}

check_link() {
    local relative_target="$1"
    local absolute_target="$HOME/$relative_target"
    local expected

    expected="$(expected_link_target "$relative_target")" || return 0

    if [[ ! -L "$absolute_target" ]]; then
        fail "$relative_target is not a symlink"
        return
    fi

    if [[ ! "$absolute_target" -ef "$expected" ]]; then
        fail "$relative_target points to $(readlink "$absolute_target"), expected $expected"
        return
    fi

    pass "$relative_target points to expected dotfiles target"
}

check_tool() {
    local tool="$1"
    if command -v "$tool" >/dev/null 2>&1; then
        pass "$tool is installed"
    else
        fail "$tool is missing"
    fi
}

tool_version() {
    local tool="$1"
    local version

    case "$tool" in
        nvim) nvim --version 2>/dev/null | awk 'NR==1 { gsub(/^v/, "", $2); print $2 }' ;;
        node)
            version="$(node --version 2>/dev/null)" || return 1
            printf '%s\n' "${version#v}"
            ;;
        npm) npm --version 2>/dev/null ;;
        go) go version 2>/dev/null | awk '{ gsub(/^go/, "", $3); print $3 }' ;;
        php) php -v 2>/dev/null | awk 'NR==1 { print $2 }' ;;
        composer) composer --version 2>/dev/null | awk '{ print $3 }' ;;
        tree-sitter) tree-sitter --version 2>/dev/null | awk '{ print $2 }' ;;
        *) return 1 ;;
    esac
}

check_min_version() {
    local tool="$1"
    local have need

    need="$(dotfiles_min_version_for "$tool")"
    if [[ -z "$need" ]]; then
        return
    fi

    if ! command -v "$tool" >/dev/null 2>&1; then
        fail "$tool is missing; need at least $need"
        return
    fi

    if ! have="$(tool_version "$tool")"; then
        have=""
    fi
    if [[ -z "$have" ]]; then
        warn "Could not determine version for $tool"
        return
    fi

    if dotfiles_version_ge "$have" "$need"; then
        pass "$tool version $have satisfies minimum $need"
    else
        fail "$tool version $have is below minimum $need"
    fi
}

check_tree_sitter_cli_version() {
    local have=""

    if ! command -v tree-sitter >/dev/null 2>&1; then
        fail "tree-sitter is missing; need $DOTFILES_TREE_SITTER_CLI_VERSION"
        return
    fi

    have="$(tool_version tree-sitter || true)"
    if [[ "$have" == "$DOTFILES_TREE_SITTER_CLI_VERSION" ]]; then
        pass "tree-sitter version $have matches nvim-treesitter"
    else
        fail "tree-sitter version ${have:-unknown} is incompatible; need $DOTFILES_TREE_SITTER_CLI_VERSION"
    fi
}

check_locale() {
    if ! dotfiles_is_linux; then
        return
    fi

    if locale 2>/dev/null | grep -q 'UTF-8'; then
        pass "UTF-8 locale available"
    else
        fail "UTF-8 locale not detected"
    fi
}

check_default_shell() {
    if [[ "${SHELL:-}" == *zsh ]]; then
        pass "Default shell uses zsh"
    else
        warn "Default shell is ${SHELL:-unset}"
    fi
}

check_zsh_completion_permissions() {
    local audit_output

    if ! command -v zsh >/dev/null 2>&1; then
        warn "Skipping zsh completion audit: zsh is missing"
        return
    fi

    audit_output="$(zsh -fc 'autoload -Uz compaudit; compaudit' 2>/dev/null || true)"
    if [[ -n "$audit_output" ]]; then
        warn "zsh compaudit found insecure completion paths; run: compaudit | xargs chmod go-w"
    else
        pass "zsh completion paths pass compaudit"
    fi
}

check_lldb() {
    if ! dotfiles_is_macos; then
        return
    fi

    if command -v lldb >/dev/null 2>&1; then
        pass "lldb is available for CodeLLDB"
    else
        warn "lldb is missing; install Xcode Command Line Tools for CodeLLDB support"
    fi
}

check_emacs_app() {
    local prefix

    if ! dotfiles_is_macos; then
        return
    fi

    if [[ -x /Applications/Emacs.app/Contents/MacOS/Emacs ]]; then
        pass "Emacs.app is installed in /Applications"
        return
    fi

    if command -v brew >/dev/null 2>&1; then
        prefix="$(brew --prefix "${DOTFILES_EMACS_PLUS_FORMULA:-emacs-plus@31}" 2>/dev/null || true)"
        if [[ -n "$prefix" && -d "$prefix/Emacs.app" ]]; then
            warn "emacs-plus is installed but /Applications/Emacs.app is missing; rerun ./install.sh or copy Emacs.app from $prefix"
            return
        fi
    fi
}

verify_nvim_contract() {
    if [[ "$run_nvim_verify" -ne 1 ]]; then
        return
    fi

    if [[ ! -f "$repo_root/scripts/verify-nvim.sh" ]]; then
        fail "scripts/verify-nvim.sh is missing"
        return
    fi

    if bash "$repo_root/scripts/verify-nvim.sh"; then
        pass "Neovim contract verification passed"
    else
        fail "Neovim contract verification failed"
    fi
}

printf 'Dotfiles doctor for %s\n' "$(dotfiles_platform)"

for path in "${DOTFILES_VERIFY_LINKS_COMMON[@]}"; do
    check_link "$path"
done

if dotfiles_is_linux; then
    for tool in "${DOTFILES_LINUX_VERIFY_TOOLS[@]}"; do
        check_tool "$tool"
    done
else
    for tool in "${DOTFILES_MACOS_VERIFY_TOOLS[@]}"; do
        check_tool "$tool"
    done
fi

check_min_version nvim
check_min_version node
check_min_version npm
check_min_version go
check_min_version php
check_min_version composer
check_tree_sitter_cli_version
check_locale
check_default_shell
check_zsh_completion_permissions
check_lldb
check_emacs_app
verify_nvim_contract

printf 'Doctor summary: %s failure(s), %s warning(s)\n' "$failures" "$warnings"
if [[ "$failures" -gt 0 ]]; then
    exit 1
fi
