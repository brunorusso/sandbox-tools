# uptime.sh

This script generates an HTML report containing the server's uptime, load average, memory usage, and the current date and time.
The report is saved to /tmp/uptime.html, and you can change the directory


# Steps performed by the script:
1. Collect uptime information using the `uptime -p` command.
2. Collect load average using the `uptime` command and extract the relevant part using `awk`.
3. Collect memory usage using the `free -h` command and extract the relevant part using `grep` and `awk`.
4. Get the current date and time using the `date` command.
5. Generate an HTML file with the collected information and save it to /tmp/uptime.html.


# Show the results
To you see the script in action visit: https://www.brunorusso.com.br/uptime.html