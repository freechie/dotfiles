#!/usr/bin/env bats

@test "repo does not contain machine-local Finder metadata" {
  run bash -c 'find . \( -path ./.git -o -path ./.cursor \) -prune -o -name ".DS_Store" -print'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "repo does not carry local Neovim runtime artifacts" {
  [ ! -e "nvim/python-venv" ]
  [ ! -e "nvim/nvim" ]
}

@test "repo does not hardcode this machine's dotfiles checkout path" {
  run bash -c 'grep -R --exclude-dir=.git --exclude-dir=.cursor "[/]Users/what/Sites/dotfiles" -- .'
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

@test "reachable git history has no Cursor agent attribution" {
  run git log --format=%B
  [ "$status" -eq 0 ]
  ! [[ "$output" == *"cursoragent@cursor.com"* ]]
}
