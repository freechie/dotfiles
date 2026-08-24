#!/usr/bin/env bats

setup() {
  export HOME="$BATS_TEST_TMPDIR"
}

@test "bash_profile loads shared environment" {
  run bash -lc 'source ./.bash_profile; printf "%s\n%s\n%s\n" "$EDITOR" "$VISUAL" "$LANG"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"nvim"* ]]
  [[ "$output" == *"en_US.UTF-8"* ]]
}

@test "bash_profile loads macOS-specific path and aliases" {
  run env DOTFILES_PLATFORM=macos bash -lc 'source ./.bash_profile; printf "%s\n" "$PATH"; alias icloud; type update'
  [ "$status" -eq 0 ]
  [[ "$output" == *"/opt/homebrew/bin"* ]]
  [[ "$output" == *"icloud="* ]]
  [[ "$output" == *"update is a function"* ]]
}

@test "bash_profile prefers user-installed tools over Homebrew" {
  run env DOTFILES_PLATFORM=macos bash --noprofile --norc -c '
    PATH=/usr/bin:/bin
    source ./.bash_profile
    IFS=: read -r -a path_parts <<< "$PATH"
    local_index=0
    brew_index=0
    for index in "${!path_parts[@]}"; do
      [ "${path_parts[$index]}" = "$HOME/.local/bin" ] && local_index="$index"
      [ "${path_parts[$index]}" = "/opt/homebrew/bin" ] && brew_index="$index"
    done
    [ "$local_index" -lt "$brew_index" ]
  '

  [ "$status" -eq 0 ]
}

@test "bash_profile loads Linux-specific path and update function" {
  run env DOTFILES_PLATFORM=linux PATH=/usr/bin:/bin:/usr/sbin:/sbin bash -lc 'source ./.bash_profile; printf "%s\n" "$PATH"; type update'
  [ "$status" -eq 0 ]
  [[ "$output" != *"/opt/homebrew/bin"* ]]
  [[ "$output" == *".local/bin"* ]]
  [[ "$output" == *"update is a function"* ]]
}

@test "platform profiles do not require optional language managers" {
  run env HOME="$HOME" PATH=/usr/bin:/bin bash --noprofile --norc -c '
    source ./platforms/macos/.bash_profile
    source ./platforms/ubuntu/.bash_profile
    printf "loaded\n"
  '

  [ "$status" -eq 0 ]
  [ "$output" = "loaded" ]
}
