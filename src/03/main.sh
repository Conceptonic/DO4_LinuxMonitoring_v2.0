#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/validate.sh"
source "${SCRIPT_DIR}/lib/cleanup_by_log.sh"
source "${SCRIPT_DIR}/lib/cleanup_by_date.sh"
source "${SCRIPT_DIR}/lib/cleanup_by_mask.sh"

print_usage() {
    echo "Usage: $0 <mode>"
    echo ""
    echo "Modes:"
    echo "  1 — Clean up by log file"
    echo "  2 — Clean up by creation date/time range"
    echo "  3 — Clean up by name mask (letters + date)"
    echo ""
    echo "Example: $0 1"
}

main() {
    if [[ $# -ne 1 ]]; then
        print_usage
        exit 1
    fi

    local mode="$1"

    validate_mode "$mode" || exit 1

    case "$mode" in
        1) cleanup_by_log ;;
        2) cleanup_by_date ;;
        3) cleanup_by_mask ;;
    esac
}

main "$@"