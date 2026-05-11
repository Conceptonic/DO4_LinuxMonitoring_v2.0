#!/bin/bash

# Nginx Combined Log Format Generator
# Generates 5 log files, one per day, with 100-1000 random entries each.
#
# HTTP Response codes used:
#   200 - OK                    : запрос выполнен успешно
#   201 - Created               : ресурс успешно создан
#   400 - Bad Request           : некорректный запрос от клиента
#   401 - Unauthorized          : требуется аутентификация
#   403 - Forbidden             : доступ запрещён
#   404 - Not Found             : ресурс не найден
#   500 - Internal Server Error : внутренняя ошибка сервера
#   501 - Not Implemented       : метод не поддерживается сервером
#   502 - Bad Gateway           : ошибка шлюза
#   503 - Service Unavailable   : сервис временно недоступен

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/generate_ip.sh"
source "${SCRIPT_DIR}/lib/generate_entry.sh"
source "${SCRIPT_DIR}/lib/generate_log.sh"

OUTPUT_DIR="${SCRIPT_DIR}/logs"
mkdir -p "$OUTPUT_DIR"

# Generate 5 log files, starting from 5 days ago
for (( i=4; i>=0; i-- )); do
    day_offset=$i
    log_date=$(date -d "$day_offset days ago" '+%Y-%m-%d')
    log_file="${OUTPUT_DIR}/access_${log_date}.log"
    echo "Generating log for $log_date → $log_file"
    generate_log "$log_date" "$log_file"
done

echo ""
echo "Done. Logs saved to: $OUTPUT_DIR"