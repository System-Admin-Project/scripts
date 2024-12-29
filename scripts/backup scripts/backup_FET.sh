#!/bin/bash

#backup_directory
BACKUP_DIR="/home/hinablack/FET_backups"

#source directory
SOURCE_DIR="/home/hinablack/FET"

#rclone remote directories
RCLONE_DIR="Admin:"

#log file path
LOG_FILE="/home/hinablack/FET_backups/backup_$(date +%Y-%m-%d_%H:%M)_log.txt"

#backup file name
BACKUP_FILE="FET_backup_$(date +%Y-%m-%d_%H:%M)/"

#check if rsync is installed
if ! command -v rsync > /dev/null 2>&1
then 
	echo "This script requires rsync to be installed."
	echo "Please use your distributions package manager to install it and try again"
	exit 2
fi
  
echo "Local system back up log" >>"$LOG_FILE"
#backup source directory using rsync
rsync -avz --progress --backup-dir="$BACKUP_DIR/$BACKUP_FILE" "$SOURCE_DIR/" "$BACKUP_DIR/" >>"$LOG_FILE"  


#verity if the backup was created successfully
if [ $? -eq 0 ]; then 
	echo "local Backup successful : $BACKUP_FILE"
else
	echo "Backup Failed!"
	exit 1
fi

#log the local backup details
echo "* * * * * * * * * * * * ** * * * * * * * * * * * * * ** * * * " >>"$LOG_FILE"
echo "Backup created: $(date +%Y-%m-%d_%H:%M:%S)" >>"$LOG_FILE"
echo "Backup file name: $BACKUP_FILE" >>"$LOG_FILE"
echo "Backup file path: $BACKUP_DIR/ $BACKUP_FILE" >>"$LOG_FILE"
echo "Source directory: $SOURCE_DIR" >>"$LOG_FILE"
echo "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _  _  _ _ _ _ _ _ _ _ _ _ " >>"$LOG_FILE"

echo "starting backup from $SOURCE_DIR to $RCLONE_DIR / ...."
rclone sync "$BACKUP_DIR" "$RCLONE_DIR" --progress 

#verity if the  cloud backup was created successfully
if [ $? -eq 0 ]; then 
	echo "Cloud Backup successful"
else
	echo "Cloud Backup Failed!"
	exit 1
fi
#to check log un-comment the next 2 lines
#echo "Displaying Log File"
#cat  /home/hinablack/FET_backups/backup_$(date +%Y-%m-%d_%H:%M)_log.txt

echo "BACKUP PROCESS COMPLETED SUCESSFULLY !"
