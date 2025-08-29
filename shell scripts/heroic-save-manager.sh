#!/bin/bash
# heroic-save-manager.sh
# Backup & restore Heroic + non-Heroic save files on Linux, organized by game
# Includes Heroic metadata (legendaryConfig.json, gog_store.json)

BACKUP_DIR="$HOME/Heroic_Backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/heroic_saves_$TIMESTAMP.tar.gz"

# Heroic metadata configs
HEROIC_META_FILES=(
  ".config/heroic/legendaryConfig.json"
  ".config/heroic/gog_store.json"
  ".var/app/com.heroicgameslauncher.hgl/config/heroic/legendaryConfig.json"
  ".var/app/com.heroicgameslauncher.hgl/config/heroic/gog_store.json"
)

# Common dirs to scan outside Heroic
SCAN_DIRS=(
  ".local/share"
  ".config"
  "Documents"
)

# Exclusions: shader caches, logs, temp data
EXCLUDES=(
  --exclude="*/ShaderCache*"
  --exclude="*/shadercache*"
  --exclude="*/logs*"
  --exclude="*/cache*"
  --exclude="*/temp*"
  --exclude="*/CrashDumps*"
)

# Helper: Get game name from Heroic configs
get_game_name() {
    local appid="$1"
    for meta in "${HEROIC_META_FILES[@]}"; do
        if [[ -f "$HOME/$meta" ]]; then
            local name
            name=$(jq -r --arg id "$appid" '.[$id].title // empty' "$HOME/$meta" 2>/dev/null)
            [[ -n "$name" && "$name" != "null" ]] && echo "$name" && return
        fi
    done
    echo ""
}

# Find extra saves outside Heroic
find_extra_saves() {
    EXTRA_DIRS=()
    for dir in "${SCAN_DIRS[@]}"; do
        if [[ -d "$HOME/$dir" ]]; then
            while IFS= read -r path; do
                rel_path="${path#$HOME/}"
                EXTRA_DIRS+=("$rel_path")
            done < <(find "$HOME/$dir" -type d \( -iname "*save*" -o -iname "*saves*" \))
        fi
    done
    echo "${EXTRA_DIRS[@]}"
}

list_games() {
    echo "=== Detected Heroic Games ==="
    PREFIX_DIR="$HOME/Games/Heroic/Prefixes"
    if [[ -d "$PREFIX_DIR" ]]; then
        for prefix in "$PREFIX_DIR"/*; do
            [[ -d "$prefix" ]] || continue
            game_id=$(basename "$prefix")
            game_name=$(get_game_name "$game_id")
            game_name=${game_name:-"(unknown id: $game_id)"}
            echo " - $game_name [$game_id]"
        done
    else
        echo "(none found)"
    fi

    echo -e "\n=== Detected Cloud Save Dirs ==="
    CLOUD_DIR="$HOME/Games/Heroic/Cloud Saves"
    if [[ -d "$CLOUD_DIR" ]]; then
        find "$CLOUD_DIR" -maxdepth 1 -type d | tail -n +2 | sed "s|$HOME/|- |"
    else
        echo "(none found)"
    fi

    echo -e "\n=== Extra Save Dirs (non-Heroic) ==="
    EXTRA_DIRS=($(find_extra_saves))
    if [[ ${#EXTRA_DIRS[@]} -gt 0 ]]; then
        printf ' - %s\n' "${EXTRA_DIRS[@]}"
    else
        echo "(none found)"
    fi
}

backup() {
    local target_game="$1"
    mkdir -p "$BACKUP_DIR"
    echo "Scanning for saves..."

    PREFIX_DIR="$HOME/Games/Heroic/Prefixes"
    CLOUD_DIR="$HOME/Games/Heroic/Cloud Saves"

    DIRS_TO_BACKUP=()

    # Heroic prefixes
    if [[ -d "$PREFIX_DIR" ]]; then
        for prefix in "$PREFIX_DIR"/*; do
            [[ -d "$prefix" ]] || continue
            game_id=$(basename "$prefix")
            game_name=$(get_game_name "$game_id")
            game_name=${game_name:-$game_id}

            if [[ -n "$target_game" ]]; then
                if [[ "$game_name" =~ $target_game ]]; then
                    echo "Backing up Heroic prefix for: $game_name"
                    DIRS_TO_BACKUP+=("Games/Heroic/Prefixes/$game_id")
                fi
            else
                DIRS_TO_BACKUP+=("Games/Heroic/Prefixes/$game_id")
            fi
        done
    fi

    # Heroic cloud saves
    if [[ -d "$CLOUD_DIR" ]]; then
        if [[ -n "$target_game" ]]; then
            while IFS= read -r path; do
                rel_path="${path#$HOME/}"
                if [[ "$rel_path" =~ $target_game ]]; then
                    echo "Backing up cloud save for: $target_game"
                    DIRS_TO_BACKUP+=("$rel_path")
                fi
            done < <(find "$CLOUD_DIR" -maxdepth 1 -type d)
        else
            DIRS_TO_BACKUP+=("Games/Heroic/Cloud Saves")
        fi
    fi

    # Extra saves outside Heroic
    EXTRA_DIRS=($(find_extra_saves))
    for dir in "${EXTRA_DIRS[@]}"; do
        if [[ -n "$target_game" ]]; then
            if [[ "$dir" =~ $target_game ]]; then
                echo "Backing up extra save dir: $dir"
                DIRS_TO_BACKUP+=("$dir")
            fi
        else
            DIRS_TO_BACKUP+=("$dir")
        fi
    done

    # Always include Heroic metadata if present
    for meta in "${HEROIC_META_FILES[@]}"; do
        [[ -f "$HOME/$meta" ]] && DIRS_TO_BACKUP+=("$meta")
    done

    if [[ ${#DIRS_TO_BACKUP[@]} -eq 0 ]]; then
        echo "No saves found for '$target_game'"
        exit 1
    fi

    # If per-game backup, change filename
    if [[ -n "$target_game" ]]; then
        BACKUP_FILE="$BACKUP_DIR/${target_game// /_}_saves_$TIMESTAMP.tar.gz"
    fi

    echo "Creating backup at $BACKUP_FILE"
    tar -czf "$BACKUP_FILE" -C "$HOME" --ignore-failed-read "${EXCLUDES[@]}" "${DIRS_TO_BACKUP[@]}"
    echo "Backup complete."
    echo "Saved directories:"
    printf ' - %s\n' "${DIRS_TO_BACKUP[@]}"
}

restore() {
    if [[ -z "$1" ]]; then
        echo "Usage: $0 restore <backup-file.tar.gz>"
        exit 1
    fi
    BACKUP_TO_RESTORE="$1"

    if [[ ! -f "$BACKUP_TO_RESTORE" ]]; then
        echo "Error: Backup file not found."
        exit 1
    fi

    echo "Restoring backup from $BACKUP_TO_RESTORE"
    tar -xzf "$BACKUP_TO_RESTORE" -C "$HOME"
    echo "Restore complete."
}

case "$1" in
    list)
        list_games
        ;;
    backup)
        backup "$2"   # optional game name
        ;;
    restore)
        restore "$2"
        ;;
    *)
        echo "Usage:"
        echo "  $0 list                  # show detected games and save dirs"
        echo "  $0 backup                # backup everything"
        echo "  $0 backup \"GameName\"   # backup only a specific game"
        echo "  $0 restore <file>        # restore from a backup"
        exit 1
        ;;
esac
