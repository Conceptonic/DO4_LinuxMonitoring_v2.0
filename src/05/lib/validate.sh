#!/bin/bash

validate_mode() {
    local mode="$1"
    if ! [[ "$mode" =~ ^[1-4]$ ]]; then
        echo "Error: Mode must be 1, 2, 3 or 4 (got: '$mode')."
        return 1
    fi
    return 0
}