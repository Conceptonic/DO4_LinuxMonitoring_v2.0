#!/bin/bash

cleanup_by_date() {
    echo "=== Cleanup by creation date/time range ==="
    echo ""
    echo "Enter the time range (format: YYYY-MM-DD HH:MM)"
    echo ""

    read -rp "Start datetime: " dt_start
    validate_datetime "$dt_start" || return 1

    read -rp "End datetime:   " dt_end
    validate_datetime "$dt_end" || return 1

    local ts_start ts_end
    ts_start=$(date -d "$dt_start:00" +%s 2>/dev/null)
    ts_end=$(date -d "$dt_end:59" +%s 2>/dev/null)

    if [[ -z "$ts_start" || -z "$ts_end" ]]; then
        echo "Error: Could not parse datetime values."
        return 1
    fi

    if (( ts_start > ts_end )); then
        echo "Error: Start datetime must be before or equal to end datetime."
        return 1
    fi

    echo ""
    echo "Searching for files and directories created between"
    echo "  $dt_start  and  $dt_end"
    echo ""

    local files_to_delete=()
    local dirs_to_delete=()

    local find_excludes=(
        \( 
            -path /proc
            -o -path /sys
            -o -path /dev
            -o -path /run
            -o -path /snap
            -o -path /boot
            -o -path /lost+found
            -o -path /var/lib
            -o -path /var/cache
            -o -path /var/log
            -o -path /usr/share
            -o -path /usr/lib
            -o -path /usr/lib64
        \) -prune -o
    )

    # Collect matching files
    while IFS= read -r item; do
        [[ -f "$item" ]] || continue
        local item_mtime
        item_mtime=$(stat -c %Y "$item" 2>/dev/null)
        [[ -z "$item_mtime" ]] && continue
        if (( item_mtime >= ts_start && item_mtime <= ts_end )); then
            files_to_delete+=("$item")
        fi
    done < <(find / -maxdepth 10 \
        "${find_excludes[@]}" \
        -type f \
        -regextype posix-extended \
        -regex '.*/[a-z]{5,7}_[0-9]{6}\.[a-z]{1,3}' \
        -print 2>/dev/null)

    # Collect matching directories
    while IFS= read -r item; do
        [[ -d "$item" ]] || continue
        local item_mtime
        item_mtime=$(stat -c %Y "$item" 2>/dev/null)
        [[ -z "$item_mtime" ]] && continue
        if (( item_mtime >= ts_start && item_mtime <= ts_end )); then
            dirs_to_delete+=("$item")
        fi
    done < <(find / -maxdepth 10 \
        "${find_excludes[@]}" \
        -type d \
        -regextype posix-extended \
        -regex '.*/[a-z]{5,7}_[0-9]{6}' \
        -print 2>/dev/null)

    local deleted_files=0
    local deleted_dirs=0

    for item in "${files_to_delete[@]}"; do
        rm -f "$item"
        echo "  Deleted file: $item"
        (( deleted_files++ ))
    done

    for item in "${dirs_to_delete[@]}"; do
        rm -rf "$item"
        echo "  Deleted dir:  $item"
        (( deleted_dirs++ ))
    done

    echo ""
    echo "Done. Deleted: $deleted_files file(s), $deleted_dirs dir(s)."
}