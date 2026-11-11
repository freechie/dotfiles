#!/usr/bin/env bats

@test "repo does not contain machine-local Finder metadata" {
  run bash -c 'git ls-files -z | tr "\0" "\n" | grep -E "(^|/)\.DS_Store$"'
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

@test "repo does not carry local Neovim runtime artifacts" {
  [ ! -e "nvim/python-venv" ]
  [ ! -e "nvim/nvim" ]
}

@test "repo does not hardcode this machine's dotfiles checkout path" {
  run git grep -E '[/]Users/what/Sites/dotfiles'
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

@test "reachable git history has no Cursor agent attribution" {
  run git log --format=%B
  [ "$status" -eq 0 ]
  ! [[ "$output" == *"cursoragent@cursor.com"* ]]
}
