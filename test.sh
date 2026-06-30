#!/usr/bin/env bash
# Runs the test suite for dotfiles

set -e

# Change to the root directory of the project
cd "$(dirname "$0")"

echo "Running tests..."

# Check if bats is installed
if ! command -v bats &> /dev/null; then
    echo "Error: BATS is not installed."
    echo "On Ubuntu: sudo apt-get install -y bats"
    exit 1
fi

tests=(tests/*.bats)

if [[ "${DOTFILES_TEST_SKIP_SYNTAX:-}" == "1" ]]; then
    filtered_tests=()
    for test_file in "${tests[@]}"; do
        if [[ "$(basename "$test_file")" == "syntax.bats" ]]; then
            continue
        fi
        filtered_tests+=("$test_file")
    done
    tests=("${filtered_tests[@]}")
fi

bats "${tests[@]}"
