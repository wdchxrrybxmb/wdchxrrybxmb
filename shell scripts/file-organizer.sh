#!/usr/bin/env bash

# Prompt user for the source directory
read -rp "Enter the source directory: " rawSourceDir
sourceDir=$(eval echo "$rawSourceDir")  # Expand $HOME, etc.

if [[ ! -d "$sourceDir" ]]; then
    echo "Error: Source directory does not exist."
    exit 1
fi

# Declare extension → folder mapping
declare -A extensions=(
    ["*.exe"]="Executables"
    ["*.bat"]="Executables"
    ["*.WAD"]="WADs"
    ["*.dll"]="DLLs"
    ["*.ps1"]="Scripts"
    ["*.iso"]="ISOs"
    ["*.zip"]="ZIPs"
    ["*.rar"]="RARs"
    ["*.7z"]="7Zs"
    ["*.jar"]="JARs"
    ["*.pdf"]="PDFs"
    ["*.doc"]="Docs"
    ["*.docx"]="Docs"
    ["*.txt"]="Docs"
    ["*.jpg"]="Images"
    ["*.png"]="Images"
    ["*.gif"]="Images"
    ["*.bmp"]="Images"
    ["*.mp3"]="Music"
    ["*.mp4"]="Videos"
    ["*.avi"]="Videos"
    ["*.mkv"]="Videos"
)

echo "Organizing files in: $sourceDir"

# Loop through the extensions and move files
for ext in "${!extensions[@]}"; do
    destDir="$sourceDir/${extensions[$ext]}"

    # Create the destination directory if it doesn’t exist
    [[ -d "$destDir" ]] || mkdir -p "$destDir"

    # Find files matching the extension (case-insensitive)
    shopt -s nullglob nocaseglob
    files=("$sourceDir"/$ext)
    shopt -u nocaseglob

    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            mv -n "$file" "$destDir/" 2>/dev/null
        fi
    done
done

echo "Files organized successfully!"
