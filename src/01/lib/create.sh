#!/bin/bash

# 1 GB in KB
readonly FREE_SPACE_THRESHOLD_KB=$(( 1 * 1024 * 1024 ))

check_free_space() {
    local free_kb
    free_kb=$(df / --output=avail | tail -1)
    if (( free_kb <= FREE_SPACE_THRESHOLD_KB )); then
        echo "Warning: Less than 1 GB free on /. Stopping script."
        return 1
    fi
    return 0
}

create_structure() {
    local base_path="$1"
    local num_folders="$2"
    local folder_letters="$3"
    local num_files="$4"
    local name_letters="$5"
    local ext_letters="$6"
    local size_kb="$7"
    local date_suffix="$8"
    local log_file="$9"

    local folder_names=()

    for (( f=0; f<num_folders; f++ )); do
        check_free_space || return 1

        local folder_base
        folder_base=$(generate_unique_name "$folder_letters" 7 folder_names)
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to generate unique folder name." >&2
            return 1
        fi
        folder_names+=("$folder_base")

        local folder_full_name="${folder_base}_${date_suffix}"
        local folder_path="${base_path}/${folder_full_name}"

        mkdir -p "$folder_path"
        log_folder "$log_file" "$folder_path"
        echo "Created folder: $folder_path"

        local file_names=()

        for (( i=0; i<num_files; i++ )); do
            check_free_space || return 1

            local file_base
            file_base=$(generate_unique_name "$name_letters" 7 file_names)
            if [[ $? -ne 0 ]]; then
                echo "Error: Failed to generate unique file name." >&2
                return 1
            fi
            file_names+=("$file_base")

            local ext
            ext=$(generate_name "$ext_letters" 3)

            local file_full_name="${file_base}_${date_suffix}.${ext}"
            local file_path="${folder_path}/${file_full_name}"

            dd if=/dev/zero of="$file_path" bs=1K count="$size_kb" 2>/dev/null
            log_file_entry "$log_file" "$file_path" "$size_kb"
            echo "  Created file:   $file_path (${size_kb}KB)"
        done
    done

    echo ""
    echo "Done. Log saved to: $log_file"
}