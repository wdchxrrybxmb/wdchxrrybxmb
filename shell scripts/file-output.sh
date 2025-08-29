#!/usr/bin/env bash

# Function: Get a valid directory path
get_valid_directory_path() {
    local allow_empty="$1"
    local directory=""

    while true; do
        read -rp "Enter the directory path: " rawDirectory
        directory=$(eval echo "$rawDirectory")  # Expand variables like $HOME

        if [[ -z "$directory" ]]; then
            echo "Error: Directory path cannot be empty." >&2
        elif [[ ! -d "$directory" ]]; then
            echo "Error: Directory does not exist or is not valid." >&2
        elif [[ "$allow_empty" != "true" && -z "$(find "$directory" -mindepth 1 -print -quit 2>/dev/null)" ]]; then
            echo "Error: Directory is empty." >&2
        else
            echo "$directory"
            return
        fi
    done
}

# Function: Let user select files
select_files_for_move() {
    local directory="$1"
    local -a selectedFiles=()

    mapfile -t files < <(find "$directory" -type f)

    echo "Select files to move or copy:"
    for file in "${files[@]}"; do
        read -rp "$(basename "$file") [Y/N]: " choice
        if [[ "$choice" == "Y" ]]; then
            selectedFiles+=("$file")
        else
            echo "Skipping $(basename "$file")"
        fi
    done

    echo "${selectedFiles[@]}"
}

while true; do
    directory=$(get_valid_directory_path "false")

    # Show files in a table format
    echo -e "\nFiles in $directory:\n"
    find "$directory" -type f -printf "%-30f %-10s %-10T@ %M\n" | \
        awk '{ printf "%-30s %-10s %-20s %-10s\n", $1, $2, strftime("%Y-%m-%d %H:%M:%S",$3), $4 }'

    while true; do
        read -rp "Do you want to move or copy files? (Y/N): " moveFiles
        [[ "$moveFiles" == "Y" || "$moveFiles" == "N" ]] && break
    done

    if [[ "$moveFiles" == "Y" ]]; then
        while true; do
            read -rp "Move or Copy? (M/C): " moveOrCopy
            [[ "$moveOrCopy" == "M" || "$moveOrCopy" == "C" ]] && break
        done

        selectedFiles=($(select_files_for_move "$directory"))
        if [[ ${#selectedFiles[@]} -eq 0 ]]; then
            echo "No files selected."
        else
            destinationDirectory=$(get_valid_directory_path "true")
            for file in "${selectedFiles[@]}"; do
                if [[ -f "$file" ]]; then
                    if [[ "$moveOrCopy" == "M" ]]; then
                        if mv "$file" "$destinationDirectory/"; then
                            echo "Moved $(basename "$file") → $destinationDirectory"
                        else
                            echo "Error moving $(basename "$file")"
                        fi
                    elif [[ "$moveOrCopy" == "C" ]]; then
                        if cp "$file" "$destinationDirectory/"; then
                            echo "Copied $(basename "$file") → $destinationDirectory"
                        else
                            echo "Error copying $(basename "$file")"
                        fi
                    fi
                else
                    echo "File not found: $file"
                fi
            done
        fi
    fi

    while true; do
        read -rp "Do you want to continue? (Y/N): " cont
        [[ "$cont" == "Y" || "$cont" == "N" ]] && break
    done

    [[ "$cont" == "N" ]] && break
done
