#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/validate.sh"
source "${SCRIPT_DIR}/lib/analyze.sh"

LOGS_DIR="${SCRIPT_DIR}/../04/logs"

main() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <mode>"
        echo ""
        echo "Modes:"
        echo "  1 — All entries sorted by response code"
        echo "  2 — All unique IPs"
        echo "  3 — All error requests (4xx / 5xx)"
        echo "  4 — All unique IPs from error requests"
        exit 1
    fi

    local mode="$1"
    validate_mode "$mode" || exit 1

    local log_files=("${LOGS_DIR}"/*.log)
    if [[ ! -e "${log_files[0]}" ]]; then
        echo "Error: No log files found in '${LOGS_DIR}'."
        exit 1
    fi

    echo "Using logs from: ${LOGS_DIR}"
    echo "----------------------------------------"

    case "$mode" in
        1) analyze_sorted_by_code "${log_files[@]}" ;;
        2) analyze_unique_ips "${log_files[@]}" ;;
        3) analyze_errors "${log_files[@]}" ;;
        4) analyze_unique_error_ips "${log_files[@]}" ;;
    esac
}

main "$@"