#!/bin/bash

validate_params() {
    local folder_letters="$1"
    local file_param="$2"
    local size_param="$3"

    # Param 1: 1-7 lowercase English letters only
    if ! [[ "$folder_letters" =~ ^[a-z]{1,7}$ ]]; then
        echo "Error: Parameter 1 must be 1-7 lowercase English letters (got: '$folder_letters')."
        return 1
    fi

    # Param 2: format "name.ext", name 1-7 letters, ext 1-3 letters
    if ! [[ "$file_param" =~ ^[a-z]{1,7}\.[a-z]{1,3}$ ]]; then
        echo "Error: Parameter 2 must be 'name.ext' lowercase letters" \
             "(name: 1-7 chars, ext: 1-3 chars) (got: '$file_param')."
        return 1
    fi

    # Param 3: 1-100 Mb
    local size_val="${size_param%[mM][bB]}"
    if ! [[ "$size_val" =~ ^[0-9]+$ ]] || (( size_val <= 0 )) || (( size_val > 100 )); then
        echo "Error: Parameter 3 must be a size 1-100 in Mb (e.g., '3Mb') (got: '$size_param')."
        return 1
    fi

    return 0
}