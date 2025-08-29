#!/usr/bin/env bash

# --- Reset Mode ---
if [[ "$1" == "--reset" ]]; then
    echo "Resetting global Git configurations..."
    git config --global --unset-all core.autocrlf 2>/dev/null
    git config --global --unset-all core.symlinks 2>/dev/null
    git config --global --unset-all core.longpaths 2>/dev/null
    git config --global --unset-all init.defaultBranch 2>/dev/null
    git config --global --unset-all merge.renamelimit 2>/dev/null
    git config --global --unset-all pull.rebase 2>/dev/null
    git config --global --unset-all fetch.parallel 2>/dev/null
    git config --global --unset-all user.name 2>/dev/null
    git config --global --unset-all user.email 2>/dev/null
    git config --global --unset-all core.editor 2>/dev/null

    echo "All specified Git global configs have been unset."
    echo "Current configs:"
    git config --list
    exit 0
fi

# --- Normal Setup Mode ---
userName="$1"
email="$2"
textEditor="$3"

# Prompt for missing parameters
if [[ -z "$userName" ]]; then
    read -rp "Enter your full name: " userName
    [[ -z "$userName" ]] && { echo "Error: User name cannot be empty"; exit 1; }
fi

if [[ -z "$email" ]]; then
    read -rp "Enter your email: " email
    [[ -z "$email" ]] && { echo "Error: Email cannot be empty"; exit 1; }
fi

if [[ -z "$textEditor" ]]; then
    read -rp "Enter your favorite code editor: " textEditor
    [[ -z "$textEditor" ]] && { echo "Error: Text editor cannot be empty"; exit 1; }
fi

# Timer start
start_time=$(date +%s)

# Set Git configurations
git config --global core.autocrlf input         # Linux default: convert CRLF -> LF on commit
git config --global core.symlinks true          # enable symlink support
git config --global core.longpaths true         # enable long paths (safe on Linux)
git config --global init.defaultBranch main     # default branch = main
git config --global merge.renamelimit 99999     # raise rename limit
git config --global pull.rebase false           # default merge strategy
git config --global fetch.parallel 0            # enable parallel fetching

# Set Git username/email/editor
git config --global user.name "$userName"
git config --global user.email "$email"
git config --global core.editor "$textEditor"

# Show configurations
if ! git config --list; then
    echo "Error: 'git config --list' failed"
    exit 1
fi

# Timer end
end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
echo "Saved your Git configuration in $elapsed sec"
