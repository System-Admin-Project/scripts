#!/bin/bash

#variables
SCRIPT_PATH="/home/FET/software-eng/level400/scripts/backup_FET.sh"

LOG_PATH="/home/FET_backup/backup_cron.log"

CRON_JOB="0 9-17/2 * 10-12 2-6 $SCRIPT_PATH >>$LOG_PATH 2>&1"

#Check if cron job already exists 
(crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH") && echo "Cron Job already exists." && exit 0

#add cron job
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

#verify the cron job was added
echo "Cron job added: "
crontab -l

echo "This cron job will run from october to december from 9am to 5pm every 2hours ,on Tuesdays to saturdays" >>$LOG_PATH 2>&1
