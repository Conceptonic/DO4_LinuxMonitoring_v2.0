#!/bin/bash

PORT=7890

start_server() {
    local script_dir="$1"
    local ip
    ip=$(hostname -I | awk '{print $1}')

    echo ""
    echo "Open in browser: http://${ip}:${PORT}/report.html"
    echo "Press Ctrl+C to stop."
    cd "$script_dir" && python3 -m http.server "$PORT"
}