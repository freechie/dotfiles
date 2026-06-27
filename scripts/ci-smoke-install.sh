#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

platform="${1:-}"
mode="${2:-full}"

if [[ -z "$platform" ]]; then
    case "$(uname -s)" in
        Darwin) platform="macos" ;;
        Linux) platform="linux" ;;
        *)
            echo "Unsupported platform: $(uname -s)" >&2
            exit 1
            ;;
    esac
fi

assert_link() {
    local target="$1"
    local expected="$2"

    test "$(readlink "$target")" = "$expected"
}

assert_clean_worktree() {
    git diff --exit-code
    test -z "$(git status --short)"
}

run_timed() {
    local label="$1"
    local start end elapsed status
    shift

    printf 'CI timing: starting %s...\n' "$label"
    start="$(date +%s)"
    if "$@"; then
        status=0
    else
        status=$?
    fi
    end="$(date +%s)"
    elapsed=$((end - start))

    if [[ "$status" -eq 0 ]]; then
        printf 'CI timing: %s completed in %ss\n' "$label" "$elapsed"
    else
        printf 'CI timing: %s failed after %ss\n' "$label" "$elapsed" >&2
    fi

    return "$status"
}

smoke_shell_startup() {
    zsh -ic 'alias ls >/dev/null; command -v nvim >/dev/null'
    bash -lc 'command -v nvim >/dev/null'
}

smoke_tmux_startup() {
    local socket="ci_smoke_$$"
    local tmux_tmpdir
    tmux_tmpdir="$(mktemp -d /tmp/dotfiles-tmux.XXXXXX)"
    TMUX_TMPDIR="$tmux_tmpdir" tmux -L "$socket" -f "$HOME/.tmux.conf" start-server \; show -g prefix \; kill-server >/dev/null
}

smoke_nvim_startup() {
    DOTFILES_CI_SMOKE_NVIM=1 nvim --headless '+quitall'
}

smoke_startup() {
    nvim --version | head -n 1
    smoke_shell_startup
    smoke_tmux_startup
    smoke_nvim_startup
}

smoke_install_linux_full() {
    printf 'y\n' | ./install.sh
}

smoke_install_skip_deps() {
    printf 'y\n' | DOTFILES_CI_SMOKE_INSTALL=1 ./install.sh --skip-deps
}

smoke_install_macos_full() {
    prepare_macos_homebrew_ci
    printf 'y\n' | DOTFILES_CI_SMOKE_INSTALL=1 ./install.sh
}

prepare_macos_homebrew_ci() {
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_ENV_HINTS=1
    export HOMEBREW_NO_INSTALL_CLEANUP=1
    export HOMEBREW_NO_INSTALL_UPGRADE=1

    if ! command -v brew >/dev/null 2>&1; then
        return
    fi

    untap_homebrew_tap_if_present "aws/tap"
}

untap_homebrew_tap_if_present() {
    local target="$1"
    local tap

    while IFS= read -r tap; do
        if [[ "$tap" != "$target" ]]; then
            continue
        fi

        if ! brew untap "$target"; then
            printf 'Skipping Homebrew tap cleanup for %s; brew refused to untap it.\n' "$target" >&2
        fi
        return
    done < <(brew tap 2>/dev/null || true)
}

assert_core_tools() {
    command -v zsh
    command -v tmux
    command -v nvim
}

assert_full_linux_tools() {
    command -v tree-sitter
    command -v node
    command -v npm
    command -v ruby
    command -v go
    command -v php
    command -v composer
    command -v javac
    command -v luarocks
}

case "$platform" in
    linux)
        case "$mode" in
            full)
                run_timed "full install" smoke_install_linux_full
                run_timed "skip-deps idempotence install" smoke_install_skip_deps
                ;;
            skip-deps)
                run_timed "skip-deps install 1" smoke_install_skip_deps
                run_timed "skip-deps install 2" smoke_install_skip_deps
                ;;
            *)
                echo "Unknown Linux install mode: $mode" >&2
                exit 1
                ;;
        esac
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

        assert_link "$HOME/.zshrc" "$repo_root/platforms/ubuntu/.zshrc"
        assert_link "$HOME/.bash_profile" "$repo_root/platforms/ubuntu/.bash_profile"
        assert_link "$HOME/.config/starship.toml" "$repo_root/platforms/ubuntu/starship.toml"

        assert_core_tools
        if [[ "$mode" == "full" ]]; then
            assert_full_linux_tools
        fi
        run_timed "startup smoke" smoke_startup
        run_timed "clean worktree check" assert_clean_worktree
        ;;
    macos)
        case "$mode" in
            full)
                run_timed "full install" smoke_install_macos_full
                run_timed "skip-deps idempotence install" smoke_install_skip_deps
                ;;
            skip-deps)
                run_timed "skip-deps install 1" smoke_install_skip_deps
                run_timed "skip-deps install 2" smoke_install_skip_deps
                ;;
            *)
                echo "Unknown macOS install mode: $mode" >&2
                exit 1
                ;;
        esac

        assert_link "$HOME/.zshrc" "$repo_root/platforms/macos/.zshrc"
        assert_link "$HOME/.bash_profile" "$repo_root/platforms/macos/.bash_profile"
        assert_link "$HOME/.config/starship.toml" "$repo_root/platforms/macos/starship.toml"

        assert_core_tools
        command -v brew
        command -v lua
        run_timed "startup smoke" smoke_startup
        run_timed "clean worktree check" assert_clean_worktree
        ;;
    *)
        echo "Unknown platform argument: $platform" >&2
        exit 1
        ;;
esac
