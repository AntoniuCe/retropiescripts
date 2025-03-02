#! /bin/bash

ARGUMENT=$1

LOCAL_MEDIA_FOLDER="$HOME/ScreenSaver/"
LOCAL_GAMES_FOLDER="$HOME/RetroPie/roms/"
LOCAL_BIOS_FOLDER="$HOME/RetroPie/BIOS/"
REMOTE_MEDIA="Arcade:RetroPie/ScreenSaver"
REMOTE_GAMES="Arcade:RetroPie/Roms"
REMOTE_BIOS="Arcade:RetroPie/Bios"
GAMELIST_FOLDER="$HOME/.emulationstation/gamelists/"
IMAGE_FOLDER="$HOME/.emulationstation/downloaded_images/"
LOG_FILE="/home/pi/sync.log"

sync_folder() {
	SOURCE=$1
	DESTINATION=$2
	MESSAGE=$3
	SHOW_MESSAGE=$4  # New parameter to control screen messages

	if [ "$SHOW_MESSAGE" = true ]; then
		echo "$MESSAGE" > /dev/tty1  # Show message only for game & BIOS sync
	fi

	rclone sync "$SOURCE" "$DESTINATION" -P --log-file="$LOG_FILE" 

	if [ "$SHOW_MESSAGE" = true ]; then
		echo "Sync complete!" > /dev/tty1
	fi
}

scrape_roms() {
	killall emulationstation
	echo "Updating game list..." > /dev/tty1
	sleep 1
	
	find "$LOCAL_GAMES_FOLDER" -mindepth 1 -maxdepth 1 -type d | while read -r SYSTEM; do
		SYSTEM_NAME=$(basename "$SYSTEM")
		mkdir -p "$GAMELIST_FOLDER$SYSTEM_NAME"
		/opt/retropie/supplementary/scraper/scraper -image_dir "$IMAGE_FOLDER$SYSTEM_NAME" \
			-output_file "$GAMELIST_FOLDER$SYSTEM_NAME/gamelist.xml"
	done
	
	echo "Game list updated!" > /dev/tty1
	emulationstation >/dev/null 2>&1 &
}

case "$ARGUMENT" in
media)
	# Screensaver sync runs silently in the background
	(sync_folder "$REMOTE_MEDIA" "$LOCAL_MEDIA_FOLDER" "Syncing screensaver files..." false) &
	;;
games)
	sync_folder "$REMOTE_GAMES" "$LOCAL_GAMES_FOLDER" "Syncing game files..." true
	scrape_roms
	;;
bios)
	sync_folder "$REMOTE_BIOS" "$LOCAL_BIOS_FOLDER" "Syncing BIOS files..." true
 	echo "Restarting EmulationStation..." > /dev/tty1
	killall emulationstation
	sleep 2
	emulationstation >/dev/tty1 2>&1 &
	;;
full)
	sync_folder "$REMOTE_MEDIA" "$LOCAL_MEDIA_FOLDER" "Syncing screensaver files..." false &
	sync_folder "$REMOTE_BIOS" "$LOCAL_BIOS_FOLDER" "Syncing BIOS files..." true
	sync_folder "$REMOTE_GAMES" "$LOCAL_GAMES_FOLDER" "Syncing game files..." true
	scrape_roms
	;;
scrape)
	scrape_roms
	;;
*)
	exit 128
	;;
esac
