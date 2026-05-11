#!/bin/bash

# Generate a random valid IP address.
# Avoids reserved/invalid ranges:
#   0.x.x.x       — reserved
#   10.x.x.x      — private
#   127.x.x.x     — loopback
#   169.254.x.x   — link-local
#   172.16-31.x.x — private
#   192.168.x.x   — private
#   224-255.x.x.x — multicast / reserved
generate_ip() {
    local ip
    while true; do
        local o1=$(( RANDOM % 223 + 1 ))
        local o2=$(( RANDOM % 256 ))
        local o3=$(( RANDOM % 256 ))
        local o4=$(( RANDOM % 254 + 1 ))

        # Skip reserved ranges
        [[ $o1 -eq 10 ]] && continue
        [[ $o1 -eq 127 ]] && continue
        [[ $o1 -eq 169 && $o2 -eq 254 ]] && continue
        [[ $o1 -eq 172 && $o2 -ge 16 && $o2 -le 31 ]] && continue
        [[ $o1 -eq 192 && $o2 -eq 168 ]] && continue

        ip="${o1}.${o2}.${o3}.${o4}"
        echo "$ip"
        return
    done
}