#!/bin/bash

init_log() {
    local log_file="$1"
    local time_start="$2"
    shift 2
    {
        echo "=========================================="
        echo " Filesystem Flood Log"
        echo " Started: $time_start"
        echo " Parameters: $*"
        echo "=========================================="
    } > "$log_file"
}

log_folder() {
    local log_file="$1"
    local folder_path="$2"
    printf '[DIR]  %-80s | Created: %s\n' \
        "$folder_path" "$(date '+%Y-%m-%d %H:%M:%S')" >> "$log_file"
}

log_file_entry() {
    local log_file="$1"
    local file_path="$2"
    local size="$3"
    printf '[FILE] %-80s | Created: %s | Size: %s\n' \
        "$file_path" "$(date '+%Y-%m-%d %H:%M:%S')" "$size" >> "$log_file"
}

finalize_log() {
    local log_file="$1"
    local time_start="$2"
    local time_end="$3"
    local elapsed="$4"
    {
        echo "=========================================="
        echo " Start time  : $time_start"
        echo " End time    : $time_end"
        echo " Total time  : $elapsed"
        echo "=========================================="
    } >> "$log_file"
}