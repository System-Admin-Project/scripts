CSV_FOLDER="/root/scripts/data/FET/Level400/SoftwareEng/Attendance/2024-2025" 
ARCHIVE_FOLDER="/root/scripts/data-archives" 
ARCHIVE_INTERVAL_DAYS=1  
LAST_ARCHIVE_FILE="/root/scripts/scripts/monitoring/last_archive_date.txt" 


mkdir -p "$ARCHIVE_FOLDER"
current_date=$(date +%s)



if [ ! -f "$LAST_ARCHIVE_FILE" ]; then
  echo "Initializing archive tracking..."
  date +%s > "$LAST_ARCHIVE_FILE"
fi

last_archive_date=$(cat "$LAST_ARCHIVE_FILE")


days_since_last_archive=$(( (current_date - last_archive_date) / 86400 ))

if [ "$days_since_last_archive" -ge "$ARCHIVE_INTERVAL_DAYS" ]; then
  echo "Archiving folder: $CSV_FOLDER"
  timestamp=$(date +"%Y%m%d_%H%M%S")
  archive_name="$ARCHIVE_FOLDER/archive_$timestamp.zip"
  zip -r "$archive_name" "$CSV_FOLDER" > /dev/null
  
  echo "Folder archived to: $archive_name"
  
  date +%s > "$LAST_ARCHIVE_FILE"
  
  # Optional: Delete original files after archiving
  find "$CSV_FOLDER" -type f -exec rm -f {} \;
  echo "Original files deleted after archiving."
else
  echo "No action needed. Last archive was $days_since_last_archive days ago."
fi
