#!/usr/bin/env bash

# Function: Prompt user for a valid directory path
get_valid_directory_path() {
    local allow_empty="$1"
    local directory=""

    while true; do
        read -rp "Enter the directory path: " rawDirectory
        directory=$(eval echo "$rawDirectory")  # expand variables like $HOME

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

while true; do
    directory=$(get_valid_directory_path "false")

    echo "Choose an operation:"
    echo "  1: Copy"
    echo "  2: Move"
    echo "  3: Rename"
    echo "  4: Delete"
    echo "  5: Zip"
    echo "  6: Unzip"
    echo "  7: Exit"
    read -rp "Enter the operation number (1-7): " operation

    # Exit early if user chooses option 7
    if [[ "$operation" == "7" ]]; then
        echo "Exiting..."
        break
    fi

    destinationDirectory=$(get_valid_directory_path "true")

    case "$operation" in
        1)
            cp -r "$directory" "$destinationDirectory" && echo "Files copied successfully."
            ;;
        2)
            mv "$directory" "$destinationDirectory" && echo "Files moved successfully."
            ;;
        3)
            read -rp "Enter the new name: " newName
            mv "$directory" "$(dirname "$directory")/$newName" && echo "Renamed successfully."
            ;;
        4)
            rm -rf "$directory" && echo "Files or folder deleted successfully."
            ;;
        5)
            read -rp "Enter the ZIP file name (without extension): " zipFileName
            zipFilePath="$destinationDirectory/$zipFileName.zip"
            zip -r "$zipFilePath" "$directory" && echo "Files compressed into archive successfully."
            ;;
        6)
            read -rp "Enter the path to the ZIP archive: " rawZipFilePath
            zipFilePath=$(eval echo "$rawZipFilePath")
            unzip "$zipFilePath" -d "$destinationDirectory" && echo "Files extracted successfully."
            ;;
        *)
            echo "Invalid operation number. Please enter between 1-7."
            ;;
    esac

    while true; do
        read -rp "Do you want to perform another operation? (Y/N): " continue
        [[ "$continue" == "Y" || "$continue" == "N" ]] && break
    done

    [[ "$continue" == "N" ]] && break
done
