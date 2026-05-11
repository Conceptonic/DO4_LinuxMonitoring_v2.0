#!/bin/bash

INTERVAL=3

run_loop() {
    while true; do
        write_metrics
        sleep "$INTERVAL"
    done
}