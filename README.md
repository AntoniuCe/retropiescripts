# retropiescripts
Improved RetroPie scripts for a phisical arcade running retropie on a raspberry pi

I improved the existing scripts wich were running both rclone and rsync on an arcade, with rclone using the mount function wich was not a good performance script

i replaced the rclone mount with and rsync with using only rclone sync from a google drive to the local folder and then rclone sync from the local folder to the actual folder in the retropie running emulation 

rewrote some of the arcade-sync because it was opening a windows with the tile syncing but only for the command line, not the actual retropie screen wich is /dev/tty1, rewrote that so it will actually open a window with a message but only for bios update and game updates, not for screensaver files which are not performance problem, for the game and bios update i will prompt a message and then kill the emulation, do the update and after i will restart the emulation
