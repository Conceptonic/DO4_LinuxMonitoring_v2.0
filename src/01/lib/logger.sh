#!/bin/bash

init_log() {
    local log_file="$1"
    shift
    {
        echo "=========================================="
        echo " File Generator Log"
        echo " Started: $(date '+%Y-%m-%d %H:%M:%S')"
        echo " Parameters: $*"
        echo "=========================================="
    } > "$log_file"
}

log_folder() {
    local log_file="$1"
    local folder_path="$2"
    printf '[DIR]  %-70s | Created: %s\n' \
        "$folder_path" "$(date '+%Y-%m-%d %H:%M:%S')" >> "$log_file"
}

log_file_entry() {
    local log_file="$1"
    local file_path="$2"
    local size_kb="$3"
    printf '[FILE] %-70s | Created: %s | Size: %sKB\n' \
        "$file_path" "$(date '+%Y-%m-%d %H:%M:%S')" "$size_kb" >> "$log_file"
}