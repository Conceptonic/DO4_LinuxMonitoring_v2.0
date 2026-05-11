#!/bin/bash

validate_mode() {
    local mode="$1"
    if ! [[ "$mode" =~ ^[123]$ ]]; then
        echo "Error: Mode must be 1, 2, or 3 (got: '$mode')."
        return 1
    fi
    return 0
}

validate_datetime() {
    local dt="$1"
    # Expected format: YYYY-MM-DD HH:MM
    if ! [[ "$dt" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}$ ]]; then
        echo "Error: Datetime must be in format 'YYYY-MM-DD HH:MM' (got: '$dt')."
        return 1
    fi
    return 0
}

validate_log_file() {
    local log_file="$1"
    if [[ -z "$log_file" ]]; then
        echo "Error: Log file path cannot be empty."
        return 1
    fi
    if [[ ! -f "$log_file" ]]; then
        echo "Error: Log file not found: '$log_file'."
        return 1
    fi
    return 0
}

validate_mask() {
    local mask="$1"
    # Mask must be lowercase letters only (the letters part of the name)
    if ! [[ "$mask" =~ ^[a-z]+$ ]]; then
        echo "Error: Mask must consist of lowercase English letters only (got: '$mask')."
        return 1
    fi
    return 0
}

validate_date_suffix() {
    local suffix="$1"
    # DDMMYY — 6 digits
    if ! [[ "$suffix" =~ ^[0-9]{6}$ ]]; then
        echo "Error: Date suffix must be 6 digits in DDMMYY format (got: '$suffix')."
        return 1
    fi
    return 0
}