#!/bin/bash

# Output file
output_file="/home/pi/.cache/monitoring_data.csv"

# Function to remove data older than 24 hours
remove_old_data() {
	# Calculate the timestamp for 24 hours ago
	timestamp_cutoff=$(date -d '24 hours ago' +"%Y-%m-%d %H:%M:%S")

	# Remove lines older than 24 hours from the CSV file
	awk -v cutoff="$timestamp_cutoff" -F ',' '$1 > cutoff' "$output_file" >temp_file && mv temp_file "$output_file"
}

# Check if the file exists, if not, create it and add headers
if [ ! -e "$output_file" ]; then
	echo "Timestamp,CPU_Temperature,RAM_Usage,CPU_Usage" >"$output_file"
fi

# Function to get CPU temperature
get_cpu_temperature() {
	temperature=$(cat /sys/class/thermal/thermal_zone0/temp)
	temperature=$(echo "scale=2; $temperature/1000" | bc)
	echo "$temperature"
}

# Function to get RAM usage
get_ram_usage() {
	ram_usage=$(free -m | awk '/Mem:/ {print $3}')
	echo "$ram_usage"
}

# Function to get CPU usage
get_cpu_usage() {
	cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
	echo "$cpu_usage"
}

# Main loop
while true; do
	timestamp=$(date +"%Y-%m-%d %H:%M:%S")
	cpu_temperature=$(get_cpu_temperature)
	ram_usage=$(get_ram_usage)
	cpu_usage=$(get_cpu_usage)

	# Append data to CSV file
	echo "$timestamp,$cpu_temperature,$ram_usage,$cpu_usage" >>"$output_file"

	# Remove data older than 24 hours
	remove_old_data

	sleep 30
done
