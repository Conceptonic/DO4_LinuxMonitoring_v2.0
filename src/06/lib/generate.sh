#!/bin/bash

generate_report() {
    local script_dir="$1"
    local logs_dir="${script_dir}/../04/logs"
    local report="${script_dir}/report.html"

    if ! ls "${logs_dir}"/*.log &>/dev/null; then
        echo "Error: No log files found in '${logs_dir}'."
        exit 1
    fi

    echo "Generating report: $report"
    cat "${logs_dir}"/*.log | goaccess \
        --log-format=COMBINED \
        --no-global-config \
        - -o "$report"

    echo "Report generated: $report"
}