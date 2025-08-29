#!/usr/bin/env bash

# Number of days to keep files
days=7

# Always clean these (per-user)
userDirs=(
    "$HOME/Downloads"
    "$HOME/.cache"
    "$HOME/.local/share/Trash/files"
)

# Only clean these if running as root
systemDirs=(
    "/tmp"
    "/var/tmp"
    "/var/cache"
    "/var/log"
)

echo "Starting cleanup..."
echo "Keeping files newer than $days days."

# Function to clean directories
cleanup_dirs() {
    local dirs=("$@")
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo "Cleaning: $dir"

            # Remove empty directories (except Downloads)
            if [[ "$dir" != "$HOME/Downloads" ]]; then
                find "$dir" -type d -empty -delete 2>/dev/null
            fi

            # Remove files older than N days
            find "$dir" -type f -mtime +"$days" -exec rm -f {} \; 2>/dev/null
        else
            echo "Skipping missing directory: $dir"
        fi
    done
}

# Clean user dirs
cleanup_dirs "${userDirs[@]}"

# If root, also clean system dirs
if [[ "$EUID" -eq 0 ]]; then
    echo "Running as root → cleaning system-wide directories..."
    cleanup_dirs "${systemDirs[@]}"
else
    echo "Not running as root → skipping system-wide cleanup."
    echo "Use: sudo $0  to clean system-wide directories."
fi

echo "Cleanup completed at $(date)"
sleep 5
