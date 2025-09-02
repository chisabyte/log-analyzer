#!/bin/bash

# Simple Log Analyzer for Failed Logins
# Author: Daniel Chisasura
# This script identifies potential brute-force attacks by counting failed login attempts from unique IP addresses.

# --- CONFIGURATION ---
LOG_FILE="/var/log/auth.log" # The log file to be analyzed.
FAILED_LOGIN_THRESHOLD=5     # The threshold for failed login attempts.

# --- SCRIPT LOGIC ---

# Check if the log file exists and is readable.
if [ ! -r "$LOG_FILE" ]; then
    echo "Error: Log file not found or is not readable at $LOG_FILE"
    exit 1
fi

echo "?? Analyzing log file: $LOG_FILE"
echo "Threshold for alerts is set to $FAILED_LOGIN_THRESHOLD failed attempts."
echo "------------------------------------------------------------"

# Use 'grep' to filter for "Failed password", extract IPs, count unique IPs,
# sort them, and then use 'awk' to print alerts for any IPs over the threshold.
grep "Failed password" "$LOG_FILE" \
    | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" \
    | sort \
    | uniq -c \
    | sort -nr \
    | awk -v threshold="$FAILED_LOGIN_THRESHOLD" '
        {
            if ($1 > threshold) {
                printf "?? ALERT: IP Address %-15s failed login %d times.\n", $2, $1
            }
        }
    '

echo "------------------------------------------------------------"
echo "? Analysis complete."