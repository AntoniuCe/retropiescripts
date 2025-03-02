#!/usr/bin/python3

import xml.etree.ElementTree as ET
import os
import shutil

GAMELIST_FOLDER = '/home/pi/.emulationstation/gamelists/'

# Get all folders in the gamelist directory
folders = [f for f in os.listdir(GAMELIST_FOLDER) if os.path.isdir(os.path.join(GAMELIST_FOLDER, f))]

for folder in folders:
    gamelist_file = os.path.join(GAMELIST_FOLDER, folder, 'gamelist.xml')
    
    if not os.path.exists(gamelist_file):
        print(f"Skipping {folder}: No gamelist.xml found.")
        continue

    try:
        # Backup the original file before modifying
        backup_file = gamelist_file + ".bak"
        if not os.path.exists(backup_file):  # Avoid overwriting previous backups
            shutil.copy2(gamelist_file, backup_file)

        tree = ET.parse(gamelist_file)
        root = tree.getroot()
        updated = False

        for game in root.findall('game'):
            if not game.find('kidgame'):
                kidgame = ET.Element('kidgame')
                kidgame.text = 'true'
                game.append(kidgame)
                updated = True  # Flag that we made changes

        if updated:
            tree.write(gamelist_file, encoding="utf-8", xml_declaration=True)
            print(f"Updated {gamelist_file}")
        else:
            print(f"No changes needed for {gamelist_file}")

    except ET.ParseError:
        print(f"Error parsing {gamelist_file}, skipping.")

print("Game list sync complete!")
