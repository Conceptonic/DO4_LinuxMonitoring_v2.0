#!/bin/bash

readonly FREE_SPACE_THRESHOLD_GB=1

check_free_space() {
    local avail
    avail=$(df -h / | awk 'NR==2 {print $4}')

    local unit="${avail: -1}"
    local int_value="${avail%?}"
    int_value="${int_value%%.*}"

    case "$unit" in
        G|g)
            if (( int_value < FREE_SPACE_THRESHOLD_GB )); then
                echo "Warning: Less than 1 GB free on /. Stopping."
                return 1
            fi
            ;;
        M|m|K|k)
            echo "Warning: Less than 1 GB free on /. Stopping."
            return 1
            ;;
        *)
            echo "Warning: Could not parse free space ('$avail'). Stopping."
            return 1
            ;;
    esac
    return 0
}

collect_target_dirs() {
    find / -maxdepth 5 -type d 2>/dev/null \
        | grep -vE '/(s?bin)(/|$)' \
        | grep -vE '^/proc'        \
        | grep -vE '^/sys'         \
        | grep -vE '^/dev'         \
        | grep -vE '^/run'         \
        | while IFS= read -r dir; do
            [[ -w "$dir" ]] && echo "$dir"
          done
}

create_structure() {
    local folder_letters="$1"
    local name_letters="$2"
    local ext_letters="$3"
    local size_mb="$4"
    local date_suffix="$5"
    local log_file="$6"

    echo "Collecting writable directories..."
    local target_dirs=()
    mapfile -t target_dirs < <(collect_target_dirs)

    if (( ${#target_dirs[@]} == 0 )); then
        echo "Error: No writable directories found."
        return 1
    fi

    echo "Found ${#target_dirs[@]} writable directories."

    local max_folders=100
    local folder_count=0
    local folder_names_used=()

    while (( folder_count < max_folders )); do
        check_free_space || return 0

        local rand_dir_idx=$(( RANDOM % ${#target_dirs[@]} ))
        local target_dir="${target_dirs[$rand_dir_idx]}"

        local folder_base
        folder_base=$(generate_unique_name "$folder_letters" 7 folder_names_used 5)

        if [[ $? -ne 0 ]]; then
            echo "Warning: Unique folder names exhausted, resetting name pool."
            folder_names_used=()
            folder_base=$(generate_unique_name "$folder_letters" 7 folder_names_used 5)
            if [[ $? -ne 0 ]]; then
                echo "Error: Cannot generate any folder name. Stopping."
                return 1
            fi
        fi

        folder_names_used+=("$folder_base")

        local folder_full="${folder_base}_${date_suffix}"
        local folder_path="${target_dir}/${folder_full}"

        mkdir -p "$folder_path" 2>/dev/null || {
            echo "  Skipping (cannot create): $folder_path"
            continue
        }

        log_folder "$log_file" "$folder_path"
        echo "Created folder: $folder_path"

        local num_files=$(( RANDOM % 20 + 1 ))
        local file_names_used=()

        for (( i=0; i<num_files; i++ )); do
            check_free_space || return 0

            local file_base
            file_base=$(generate_unique_name "$name_letters" 7 file_names_used 5)

            if [[ $? -ne 0 ]]; then
                echo "  Warning: Unique file names exhausted, resetting name pool."
                file_names_used=()
                file_base=$(generate_unique_name "$name_letters" 7 file_names_used 5)
                if [[ $? -ne 0 ]]; then
                    echo "  Warning: Cannot generate file name, skipping remaining files."
                    break
                fi
            fi

            file_names_used+=("$file_base")

            local ext
            ext=$(generate_name "$ext_letters" 3 1)

            local file_full="${file_base}_${date_suffix}.${ext}"
            local file_path="${folder_path}/${file_full}"

            dd if=/dev/urandom of="$file_path" bs=1M count="$size_mb" 2>/dev/null
            log_file_entry "$log_file" "$file_path" "${size_mb}Mb"
            echo "  Created file: $file_path (${size_mb}Mb)"
        done

        (( folder_count++ ))
    done

    echo "Reached folder limit (${max_folders})."
}