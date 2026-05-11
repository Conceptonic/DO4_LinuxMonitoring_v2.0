#!/bin/bash

validate_params() {
    local path="$1"
    local num_folders="$2"
    local folder_letters="$3"
    local num_files="$4"
    local file_param="$5"
    local size_param="$6"

    # Param 1: absolute path
    if [[ "$path" != /* ]]; then
        echo "Error: Parameter 1 must be an absolute path (got: '$path')."
        return 1
    fi

    # Param 2: positive integer
    if ! [[ "$num_folders" =~ ^[0-9]+$ ]] || (( num_folders <= 0 )); then
        echo "Error: Parameter 2 must be a positive integer (got: '$num_folders')."
        return 1
    fi

    # Param 3: 1-7 lowercase English letters only
    if ! [[ "$folder_letters" =~ ^[a-z]{1,7}$ ]]; then
        echo "Error: Parameter 3 must be 1-7 lowercase English letters (got: '$folder_letters')."
        return 1
    fi

    # Param 4: positive integer
    if ! [[ "$num_files" =~ ^[0-9]+$ ]] || (( num_files <= 0 )); then
        echo "Error: Parameter 4 must be a positive integer (got: '$num_files')."
        return 1
    fi

    # Param 5: format is "name_letters.ext_letters"
    # name: 1-7 lowercase letters, ext: 1-3 lowercase letters
    if ! [[ "$file_param" =~ ^[a-z]{1,7}\.[a-z]{1,3}$ ]]; then
        echo "Error: Parameter 5 must be 'name.ext' with lowercase letters" \
             "(name: 1-7 chars, ext: 1-3 chars) (got: '$file_param')."
        return 1
    fi

    # Param 6: positive integer 1-100, optionally followed by kb/KB
    local size_val="${size_param%[kK][bB]}"
    if ! [[ "$size_val" =~ ^[0-9]+$ ]] || (( size_val <= 0 )) || (( size_val > 100 )); then
        echo "Error: Parameter 6 must be a size 1-100 in kb (e.g., '3kb') (got: '$size_param')."
        return 1
    fi

    return 0
}