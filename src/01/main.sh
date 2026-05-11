#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/validate.sh"
source "${SCRIPT_DIR}/lib/generate.sh"
source "${SCRIPT_DIR}/lib/create.sh"
source "${SCRIPT_DIR}/lib/logger.sh"

main() {
    if [[ $# -ne 6 ]]; then
        echo "Usage: $0 <abs_path> <num_folders> <folder_letters> <num_files> <name_letters.ext_letters> <sizeKb>"
        echo "Example: $0 /opt/test 4 az 5 az.az 3kb"
        exit 1
    fi

    local base_path="$1"
    local num_folders="$2"
    local folder_letters="$3"
    local num_files="$4"
    local file_param="$5"
    local size_param="$6"

    validate_params "$base_path" "$num_folders" "$folder_letters" \
                    "$num_files" "$file_param" "$size_param" || exit 1

    local size_kb="${size_param%[kK][bB]}"
    local name_letters="${file_param%%.*}"
    local ext_letters="${file_param##*.}"
    local date_suffix
    date_suffix=$(date +"%d%m%y")

    mkdir -p "$base_path" || {
        echo "Error: Cannot create base directory '$base_path'."
        exit 1
    }

    local log_file="${SCRIPT_DIR}/log_${date_suffix}.txt"
    init_log "$log_file" "$@"

    create_structure \
        "$base_path" "$num_folders" "$folder_letters" \
        "$num_files" "$name_letters" "$ext_letters" \
        "$size_kb" "$date_suffix" "$log_file"
}

main "$@"