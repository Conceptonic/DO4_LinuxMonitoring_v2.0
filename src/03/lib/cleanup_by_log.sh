#!/bin/bash

cleanup_by_log() {
    echo "=== Cleanup by log file ==="
    echo ""

    read -rp "Enter full path to the log file (from Part 2): " log_file
    validate_log_file "$log_file" || return 1

    echo ""
    echo "Parsing log file: $log_file"
    echo ""

    local deleted_files=0
    local deleted_dirs=0
    local failed=0
    local dirs_to_delete=()

    while IFS= read -r line; do
        if [[ "$line" =~ ^\[FILE\] ]]; then
            # Extract path: between first space after [FILE] and " | Created:"
            local file_path
            file_path=$(echo "$line" | sed 's/^\[FILE\] \+//' | sed 's/ *| Created:.*$//')
            file_path="${file_path%"${file_path##*[^ ]}"}"  # trim trailing spaces
            if [[ -f "$file_path" ]]; then
                rm -f "$file_path"
                echo "  Deleted file: $file_path"
                (( deleted_files++ ))
            else
                echo "  Not found (skip): $file_path"
                (( failed++ ))
            fi
        elif [[ "$line" =~ ^\[DIR\] ]]; then
            local dir_path
            dir_path=$(echo "$line" | sed 's/^\[DIR\] \+//' | sed 's/ *| Created:.*$//')
            dir_path="${dir_path%"${dir_path##*[^ ]}"}"  # trim trailing spaces
            dirs_to_delete+=("$dir_path")
        fi
    done < "$log_file"

    # Delete directories in reverse order
    for (( i=${#dirs_to_delete[@]}-1; i>=0; i-- )); do
        local dir="${dirs_to_delete[$i]}"
        if [[ -d "$dir" ]]; then
            rm -rf "$dir"
            echo "  Deleted dir:  $dir"
            (( deleted_dirs++ ))
        else
            echo "  Not found (skip): $dir"
        fi
    done

    echo ""
    echo "Done. Deleted: $deleted_files file(s), $deleted_dirs dir(s). Not found: $failed."
}