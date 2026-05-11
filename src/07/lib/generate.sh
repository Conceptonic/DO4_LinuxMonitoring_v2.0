#!/bin/bash

# Generate a name from `letters`:
#   - uses every letter at least once
#   - index into letters is strictly non-decreasing (never goes backward)
#   - total length is in [max(min_base, n_letters), max_len]
#
# Args: letters, max_len, min_base
generate_name() {
    local letters="$1"
    local max_len="$2"
    local min_base="${3:-5}"
    local n=${#letters}
    local min_len=$(( n > min_base ? n : min_base ))
    (( min_len > max_len )) && min_len=$max_len

    local length=$(( RANDOM % (max_len - min_len + 1) + min_len ))

    local name_chars=()
    local cur_idx=0

    for (( pos=0; pos<length; pos++ )); do
        name_chars+=("${letters:$cur_idx:1}")

        local remaining=$(( length - pos - 1 ))
        local required_left=$(( n - cur_idx - 1 ))

        if (( cur_idx < n - 1 )); then
            if (( required_left >= remaining )); then
                (( cur_idx++ ))
            elif (( RANDOM % 2 == 0 )); then
                (( cur_idx++ ))
            fi
        fi
    done

    printf '%s' "${name_chars[@]}"
}

# Generate a name not already present in the given array (passed by name).
generate_unique_name() {
    local letters="$1"
    local max_len="$2"
    local -n _existing_ref="$3"
    local min_base="${4:-5}"

    local name
    local attempts=0
    local max_attempts=1000

    while (( attempts < max_attempts )); do
        name=$(generate_name "$letters" "$max_len" "$min_base")
        local found=0
        for existing in "${_existing_ref[@]}"; do
            [[ "$existing" == "$name" ]] && found=1 && break
        done
        if (( found == 0 )); then
            echo "$name"
            return 0
        fi
        (( attempts++ ))
    done

    echo "Error: Could not generate a unique name after $max_attempts attempts." >&2
    return 1
}