#!/bin/bash

# Base directory for your data
BASE_DIR="../../data/FET/Level400/SoftwareEng/Attendance"
archives="../../data-archives"

mkdir -p "$BASE_DIR"
mkdir -p "$archives"

# Archive year folders at the end of the year
archive_yearly_folders() {
    current_year=$(date +%Y)
    echo "Archiving all year folders before $current_year..."

    # Loop through year folders
    find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r year_folder; do
    folder_name=$(basename "$year_folder")
    echo "Processing folder: $folder_name"

    # Extract the first year from the folder name
    first_year=$(echo "$folder_name" | cut -d '-' -f 1)

    # Check if the first year is a valid 4-digit number
    if [[ "$first_year" =~ ^[0-9]{4}$ ]]; then
        # Get the current year
        current_year=$(date +%Y)

        # Check if the first year is before the current year
        if (( first_year < current_year )); then
            echo "Archiving: $year_folder"
            
            # Archive the folder
            tar -czf "${archives}/${folder_name}.tar.gz" -C "$(dirname "$year_folder")" "$folder_name" && rm -r "$year_folder"
            
            echo "Archived $folder_name to ${archives}/${folder_name}.tar.gz"
        else
            echo "Skipping: $folder_name (Year is not before $current_year)"
        fi
    else
        echo "Skipping: $folder_name (Invalid year format)"
    fi
done

}

# Archive semester folders after every semester
archive_semester_folders() {
    echo "Archiving semester folders..."
    # Find all year folders
    find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r year_folder; do
        # Navigate into the year folder
        find "$year_folder" -mindepth 1 -maxdepth 1 -type d | while read -r semester_folder; do
            folder_name=$(basename "$semester_folder")
            echo "Archiving semester: $semester_folder"

            tar -czf "${semester_folder}.tar.gz" -C "$(dirname "$semester_folder")" "$folder_name" && rm -r "$semester_folder"
            echo "Archived $folder_name to ${archives}.tar.gz"
        done
    done
}

# Schedule the script using cron
setup_cron_job() {
    SCRIPT_PATH=$(realpath "$0")
    CRON_JOB_YEARLY="59 23 31 08 * $SCRIPT_PATH"

    # Check existing cron jobs
    existing_cron=$(crontab -l 2>/dev/null || true)

    # Add yearly cron job if not exists
    if ! echo "$existing_cron" | grep -qF "$CRON_JOB_YEARLY"; then
        echo "Adding yearly archival cron job..."
        (echo "$existing_cron"; echo "$CRON_JOB_YEARLY") | crontab -
    else
        echo "Yearly archival cron job already exists."
    fi
}

# Main execution
echo "Starting archive process..."
# archive_semester_folders
archive_yearly_folders
setup_cron_job
echo "Archive process completed and cron jobs set."
