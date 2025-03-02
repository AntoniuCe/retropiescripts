#!/bin/bash

# Set the time (in seconds) for inactivity before exiting RetroArch
inactivity_timeout=300 # 5 minutes
output_file="/tmp/jstest_output"
rm -f "$output_file" # Remove the file if it exists

# List of gamepad devices (full paths)
gamepad_devices=("/dev/input/js0" "/dev/input/js1")

# Function to monitor a gamepad device
monitor_device() {
	local device="$1"
	local start_time=$(date +%s) # Store the start time
	local last_file_size=0       # Store the last known file size

	# Start jstest in the background and redirect its output to a file
	jstest --event "$device" >>"$output_file" &

	# Get the process ID of the jstest command
	local jstest_pid=$!

	while true; do
		retroarch_pid=$(pgrep retroarch)
		if [ -z "$retroarch_pid" ]; then
			echo "RetroArch is not running"
			break
		fi

		# Check if the jstest process is still running
		if ! ps -p $jstest_pid >/dev/null; then
			break
		fi

		# Get the current size of the output file
		local current_file_size=$(stat -c %s "$output_file")

		# Check if the file size has changed
		if [ $current_file_size -ne $last_file_size ]; then
			# New events detected; reset the timer
			echo "Input detected"
			start_time=$(date +%s)
			last_file_size=$current_file_size
		fi

		# Check if the timeout has been reached
		local current_time=$(date +%s)
		if ((current_time - start_time >= inactivity_timeout)); then
			# No new events detected; you can exit RetroArch here
			killall retroarch
			# You can add the command to exit RetroArch here
			break
		fi

		# Sleep for a short period before checking again
		sleep 1
	done

	# Clean up by killing the jstest process
	kill $jstest_pid
}

# Iterate through the list of gamepad devices
for device in "${gamepad_devices[@]}"; do
	monitor_device "$device" &
done

# Wait for all monitoring processes to finish
wait
