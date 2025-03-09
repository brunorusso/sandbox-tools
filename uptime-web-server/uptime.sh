#!/bin/bash

# Collect uptime information
uptime_info=$(uptime -p)

# Collect load average
load_avg=$(uptime | awk -F'load average:' '{ print $2 }')

# Collect memory usage
mem_usage=$(free -h | grep Mem | awk '{print $3 "/" $2}')

# Get current date and time
current_date=$(date)

dest="/tmp/uptime.html"

# Generate HTML output
cat <<EOF > $dest
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Uptime Report</title>
</head>
<body>
    <h1>Server Uptime Report</h1>
    <p><strong>Uptime:</strong> $uptime_info</p>
    <p><strong>Load Average:</strong> $load_avg</p>
    <p><strong>Memory Usage:</strong> $mem_usage</p>
    <p><strong>Last Updated:</strong> $current_date</p>
</body>
</html>
EOF