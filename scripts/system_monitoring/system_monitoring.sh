FOLDER="/root/scripts/data/FET/Level400/SoftwareEng/Attendance/2024-2025/Semester-1"  # Path to the csv folder
THRESHOLD=1000000            #threshold size in kb
EMAIL="dionemakoge10@gmail.com"    # system admin email
LOGFILE="/root/scripts/scripts/system_monitoring/monitoring.log" # Log resukts after the script is run

# Function to calculate folder size
get_folder_size() {
  du -sk "$FOLDER" | awk '{print $1}'
}

# Function to send email using msmtp
send_email() {
  local folder_size=$1
  echo -e "Subject: Folder Size Alert\n\nThe folder at $FOLDER has exceeded the threshold of $THRESHOLD KB.\nCurrent size: $folder_size KB." | msmtp --debug --from=default "$EMAIL"
}

# Monitor folder size
folder_size=$(get_folder_size)

# Check if folder size exceeds the threshold
if (( folder_size > THRESHOLD )); then
  echo "$(date): Folder size is $folder_size KB. Sending alert email to $EMAIL." | tee -a "$LOGFILE"
  send_email "$folder_size"
else
  echo "$(date): Folder size is $folder_size KB, below the threshold of $THRESHOLD KB." | tee -a "$LOGFILE"
fi