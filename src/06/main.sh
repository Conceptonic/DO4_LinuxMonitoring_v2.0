#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/generate.sh"
source "$SCRIPT_DIR/lib/serve.sh"

check_dependencies
generate_report "$SCRIPT_DIR"
start_server "$SCRIPT_DIR"