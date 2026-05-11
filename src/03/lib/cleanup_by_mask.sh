#!/bin/bash

cleanup_by_mask() {
    echo "=== Cleanup by name mask ==="
    echo ""
    echo "The mask is built from the letter-part of the name and a date suffix."
    echo "Example: letters=az  date=090426  → matches any name like 'aazzz_090426'"
    echo ""

    read -rp "Enter letter mask (e.g. az): " mask
    validate_mask "$mask" || return 1

    read -rp "Enter date suffix in DDMMYY format (e.g. 090426): " date_suffix
    validate_date_suffix "$date_suffix" || return 1

    echo ""
    echo "Searching for items matching mask: [${mask} chars]_${date_suffix}"
    echo ""

    # Build unique character class from mask letters (preserve order, no duplicates)
    local unique_chars=""
    local seen_chars=()
    for (( i=0; i<${#mask}; i++ )); do
        local ch="${mask:$i:1}"
        local found=0
        for s in "${seen_chars[@]}"; do [[ "$s" == "$ch" ]] && found=1 && break; done
        if (( found == 0 )); then
            unique_chars+="$ch"
            seen_chars+=("$ch")
        fi
    done

    local char_class="[$unique_chars]"
    local name_regex="${char_class}{5,7}_${date_suffix}"

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

    local files_to_delete=()
    local dirs_to_delete=()

    # Collect matching files
    while IFS= read -r item; do
        [[ -f "$item" ]] || continue
        files_to_delete+=("$item")
    done < <(find / -maxdepth 10 \
        "${find_excludes[@]}" \
        -type f \
        -regextype posix-extended \
        -regex ".*/${name_regex}\.[a-z]{1,3}" \
        -print 2>/dev/null)

    # Collect matching directories
    while IFS= read -r item; do
        [[ -d "$item" ]] || continue
        dirs_to_delete+=("$item")
    done < <(find / -maxdepth 10 \
        "${find_excludes[@]}" \
        -type d \
        -regextype posix-extended \
        -regex ".*/${name_regex}" \
        -print 2>/dev/null)

    local deleted_files=0
    local deleted_dirs=0

    # Delete files first
    for item in "${files_to_delete[@]}"; do
        rm -f "$item"
        echo "  Deleted file: $item"
        (( deleted_files++ ))
    done

    # Delete directories after
    for item in "${dirs_to_delete[@]}"; do
        rm -rf "$item"
        echo "  Deleted dir:  $item"
        (( deleted_dirs++ ))
    done

    echo ""
    echo "Done. Deleted: $deleted_files file(s), $deleted_dirs dir(s)."
}