#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/validate.sh"
source "${SCRIPT_DIR}/lib/generate.sh"
source "${SCRIPT_DIR}/lib/create.sh"
source "${SCRIPT_DIR}/lib/logger.sh"

main() {
    if [[ $# -ne 3 ]]; then
        echo "Usage: $0 <folder_letters> <name_letters.ext_letters> <sizeMb>"
        echo "Example: $0 az az.az 3Mb"
        exit 1
    fi

    local folder_letters="$1"
    local file_param="$2"
    local size_param="$3"

    validate_params "$folder_letters" "$file_param" "$size_param" || exit 1

    local size_mb="${size_param%[mM][bB]}"
    local name_letters="${file_param%%.*}"
    local ext_letters="${file_param##*.}"
    local date_suffix
    date_suffix=$(date +"%d%m%y")

    local log_file="${SCRIPT_DIR}/log_${date_suffix}.txt"
    local time_start
    time_start=$(date '+%Y-%m-%d %H:%M:%S')
    local ts_start
    ts_start=$(date +%s)

    init_log "$log_file" "$time_start" "$@"

    create_structure \
        "$folder_letters" "$name_letters" "$ext_letters" \
        "$size_mb" "$date_suffix" "$log_file"

    local time_end
    time_end=$(date '+%Y-%m-%d %H:%M:%S')
    local ts_end
    ts_end=$(date +%s)
    local elapsed=$(( ts_end - ts_start ))
    local elapsed_fmt
    elapsed_fmt=$(printf '%02d:%02d:%02d' \
        $(( elapsed/3600 )) $(( (elapsed%3600)/60 )) $(( elapsed%60 )))

    echo ""
    echo "Start time : $time_start"
    echo "End time   : $time_end"
    echo "Total time : $elapsed_fmt"

    finalize_log "$log_file" "$time_start" "$time_end" "$elapsed_fmt"
}

main "$@"