#!/bin/bash

# Mode 1: All entries sorted by response code (field 9)
analyze_sorted_by_code() {
    echo "[Mode 1] All entries sorted by response code:"
    echo ""
    awk '
    {
        print $9, $0
    }
    ' "$@" | sort -k1,1n | awk '{$1=""; print substr($0,2)}'
}

# Mode 2: All unique IPs (field 1)
analyze_unique_ips() {
    echo "[Mode 2] All unique IPs:"
    echo ""
    awk '
    {
        ips[$1] = 1
    }
    END {
        for (ip in ips) print ip
    }
    ' "$@" | sort -V
}

# Mode 3: All error requests (response code 4xx or 5xx, field 9)
analyze_errors() {
    echo "[Mode 3] All error requests (4xx / 5xx):"
    echo ""
    awk '
    {
        code = $9
        if (code ~ /^[45][0-9][0-9]$/) {
            print $0
        }
    }
    ' "$@"
}

# Mode 4: All unique IPs from error requests (field 1, code 4xx/5xx)
analyze_unique_error_ips() {
    echo "[Mode 4] All unique IPs from error requests:"
    echo ""
    awk '
    {
        code = $9
        if (code ~ /^[45][0-9][0-9]$/) {
            ips[$1] = 1
        }
    }
    END {
        for (ip in ips) print ip
    }
    ' "$@" | sort -V
}