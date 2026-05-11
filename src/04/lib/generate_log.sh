#!/bin/bash

# Generate a full log file for a given day.
# Args: log_date (YYYY-MM-DD), output_file
generate_log() {
    local log_date="$1"
    local output_file="$2"

    # Random number of entries: 100-1000
    local num_entries=$(( RANDOM % 901 + 100 ))
    echo "  Entries: $num_entries"

    # Time boundaries for this day (00:00:00 to 23:59:59)
    local ts_start
    ts_start=$(date -d "${log_date} 00:00:00" +%s)
    local ts_end
    ts_end=$(date -d "${log_date} 23:59:59" +%s)
    local day_range=$(( ts_end - ts_start ))

    # Generate sorted random timestamps using awk to avoid RANDOM overflow
    local sorted_timestamps
    sorted_timestamps=$(awk \
        -v seed="$RANDOM" \
        -v count="$num_entries" \
        -v ts_start="$ts_start" \
        -v day_range="$day_range" \
        'BEGIN {
            srand(seed)
            for (i = 0; i < count; i++) {
                print int(rand() * day_range) + ts_start
            }
        }' | sort -n)

    # Write entries to file
    > "$output_file"
    while IFS= read -r ts; do
        generate_entry "$log_date" "$ts" >> "$output_file"
    done <<< "$sorted_timestamps"

    echo "  Written to: $output_file"
}