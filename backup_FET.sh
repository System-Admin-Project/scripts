#!/bin/bash

#backup_directory
BACKUP_DIR="/home/FET_backup"

#source directory
SOURCE_DIR="/home/FET"

#log file path
LOG_FILE="/home/FET_backup/backup_log.txt"

#backup file name
BACKUP_FILE="FET_backup_$(date +%Y-%m-%d_%H:%M:%S)/"

#check if rsync is installed
if ! command -v rsync > /dev/null 2>&1
then 
	echo "This script requires rsync to be installed."
	echo "Please use your distributions package manager to install it and try again"
	exit 2
fi

echo "List of files that were backed up" >>"$LOG_FILE"
#backup source directory using rsync
rsync -avz --progress --backup-dir="$BACKUP_DIR/$BACKUP_FILE" "$SOURCE_DIR/" "$BACKUP_DIR/" >>"$LOG_FILE"

#verity if the backup was created successfully
if [ $? -eq 0 ]; then 
	echo "Backup successful : $BACKUP_FILE"
else
	echo "Backup Failed!"
fi

#log the backup details
echo "* * * * * * * * * * * * ** * * * * * * * * * * * * * ** * * * " >>"$LOG_FILE"
echo "Backup created: $(date +%Y-%m-%d_%H:%M:%S)" >>"$LOG_FILE"
echo "Backup file name: $BACKUP_FILE" >>"$LOG_FILE"
echo "Backup file path: $BACKUP_DIR/ $BACKUP_FILE" >>"$LOG_FILE"
echo "Source directory: $SOURCE_DIR" >>"$LOG_FILE"
echo "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _  _  _ _ _ _ _ _ _ _ _ _ " >>"$LOG_FILE"

echo "Displaying Log File"
sudo cat  /home/FET_backup/backup_log.txt
