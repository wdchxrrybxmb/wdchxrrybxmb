#!/usr/bin/env bash

# Default to ~/Documents
cd "$HOME/Documents" || { echo "Error: Could not change to ~/Documents"; exit 1; }

# If argument not provided, prompt the user
gitRepo="$1"
if [[ -z "$gitRepo" ]]; then
    read -rp "Enter your git repository link: " gitRepo
    if [[ -z "$gitRepo" ]]; then
        echo "Error: Git repository link cannot be empty."
        exit 1
    fi
fi

# Try to clone the repo
if git clone "$gitRepo"; then
    echo "Git repository successfully cloned!"
    exit 0
else
    echo "Error: Failed to clone repository."
    exit 1
fi
