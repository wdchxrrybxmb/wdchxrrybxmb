#!/usr/bin/env bash

echo "===== Pacman (all) ====="
pacman -Q

echo -e "\n===== Pacman (explicit) ====="
pacman -Qe

echo -e "\n===== Pacman (AUR/foreign) ====="
pacman -Qm

if command -v flatpak &>/dev/null; then
    echo -e "\n===== Flatpak ====="
    flatpak list
fi

if command -v snap &>/dev/null; then
    echo -e "\n===== Snap ====="
    snap list
fi

if command -v pip &>/dev/null; then
    echo -e "\n===== Pip (system-wide) ====="
    pip list
fi
