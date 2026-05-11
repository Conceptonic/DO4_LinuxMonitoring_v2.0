#!/bin/bash

OUTPUT="/var/www/html/metrics"

get_cpu() {
    top -bn2 | grep "Cpu(s)" | tail -1 | awk '{print $8}' | tr -d '%'
}

get_mem() {
    grep -E "MemTotal|MemAvailable" /proc/meminfo | awk '{print $2 * 1024}'
}

write_metrics() {
    local cpu_idle
    cpu_idle=$(get_cpu)
    local cpu_usage
    cpu_usage=$(echo "100 - $cpu_idle" | bc 2>/dev/null || echo "0")

    local mem_values
    mapfile -t mem_values < <(get_mem)
    local mem_total="${mem_values[0]}"
    local mem_available="${mem_values[1]}"
    local mem_used=$((mem_total - mem_available))

    local disk_total disk_avail disk_used
    disk_total=$(df / --output=size -B1 | tail -1 | tr -d ' ')
    disk_avail=$(df / --output=avail -B1 | tail -1 | tr -d ' ')
    disk_used=$((disk_total - disk_avail))

    sudo tee "$OUTPUT" > /dev/null << EOF
# HELP custom_cpu_usage_percent CPU usage in percent
# TYPE custom_cpu_usage_percent gauge
custom_cpu_usage_percent ${cpu_usage}

# HELP custom_memory_total_bytes Total RAM in bytes
# TYPE custom_memory_total_bytes gauge
custom_memory_total_bytes ${mem_total}

# HELP custom_memory_available_bytes Available RAM in bytes
# TYPE custom_memory_available_bytes gauge
custom_memory_available_bytes ${mem_available}

# HELP custom_memory_used_bytes Used RAM in bytes
# TYPE custom_memory_used_bytes gauge
custom_memory_used_bytes ${mem_used}

# HELP custom_disk_total_bytes Total disk size in bytes
# TYPE custom_disk_total_bytes gauge
custom_disk_total_bytes ${disk_total}

# HELP custom_disk_available_bytes Available disk space in bytes
# TYPE custom_disk_available_bytes gauge
custom_disk_available_bytes ${disk_avail}

# HELP custom_disk_used_bytes Used disk space in bytes
# TYPE custom_disk_used_bytes gauge
custom_disk_used_bytes ${disk_used}
EOF
}