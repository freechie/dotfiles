DOTFILES_PLATFORM="${DOTFILES_PLATFORM:-$(dotfiles_platform)}"
export DOTFILES_PLATFORM

case "${DOTFILES_PLATFORM:-}" in
    macos)
        . "$DOTFILES_ROOT/shell/bash/macos.bash"
        ;;
    linux)
        . "$DOTFILES_ROOT/shell/bash/linux.bash"
        ;;
esac

. "$DOTFILES_ROOT/shell/bash/common.bash"
