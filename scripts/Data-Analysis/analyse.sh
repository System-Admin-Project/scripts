#!/bin/bash

# Base directory where attendance CSV files are stored
BASE_DIR="../../data/FET/Level400/SoftwareEng/Attendance"
THRESHOLD=70

# File containing lecturer information
LECTURERS_FILE="../Account-Management/Group_and_Txt_scriptandfile/lecturers_passwords.txt"

# Declare associative arrays to store emails and names for each course
declare -A course_emails
declare -A course_lecturers

# Function to load lecturer details from the txt file
load_lecturer_details() {
  while IFS=',' read -r lecturer_name lecturer_id username password course email; do
    # Remove leading/trailing whitespaces
    course=$(echo "$course" | xargs)
    lecturer_name=$(echo "$lecturer_name" | xargs)
    email=$(echo "$email" | xargs)
    # Map course to lecturer details
    course_emails["$course"]="$email"
    course_lecturers["$course"]="$lecturer_name"
  done < <(tail -n +2 "$LECTURERS_FILE") # Skip the header row
}

# Function to calculate attendance for all students in a course
calculate_course_attendance() {
  local course_folder=$1
  local year=$2
  local semester=$3
  local course_name=$(basename "$course_folder")

  # Declare associative arrays to track attendance
  declare -A total_classes
  declare -A attended_classes

  # Create output directories grouped by year and semester
  local output_folder="./Reports/$year/$semester/$course_name"
  mkdir -p "$output_folder"

  local detailed_file="$output_folder/${course_name}_detailed.txt"
  local summary_file="$output_folder/${course_name}_summary.txt"

  # Get lecturer name and email from the course_lecturers and course_emails arrays
  local lecturer_name="${course_lecturers[$course_name]}"
  local lecturer_email="${course_emails[$course_name]}"
  if [[ -z "$lecturer_email" || -z "$lecturer_name" ]]; then
    echo "No email or name found for course $course_name. Skipping."
    return
  fi

  # Initialize files
  echo "Detailed Attendance Report for $course_name" > "$detailed_file"
  echo "===============================" >> "$detailed_file"
  echo "Summary Report for $course_name" > "$summary_file"
  echo "===============================" >> "$summary_file"

  # Include lecturer's name and email in the summary file
  echo "Lecturer: $lecturer_name" >> "$summary_file"
  echo "Email: $lecturer_email" >> "$summary_file"
  echo "" >> "$summary_file"

  # Initialize total classes count
  local total_classes_count=0

  # Loop through CSV files in the course folder
  for file in "$course_folder"/*.csv; do
    if [[ -f "$file" ]]; then
      total_classes_count=$((total_classes_count + 1))  # Increment class count for each CSV file

      # Read the CSV file line by line (skip the header)
      while IFS=, read -r student_name matricule attendance lecture_time; do
        # Skip the header row
        if [[ "$student_name" == "Student Name" ]]; then
          continue
        fi

        # Increment total classes for the student
        total_classes["$matricule"]=$((total_classes["$matricule"] + 1))

        # Increment attended classes if marked "present"
        if [[ "$attendance" == "present" ]]; then
          attended_classes["$matricule"]=$((attended_classes["$matricule"] + 1))
        fi
      done < "$file"
    fi
  done

  # Calculate attendance percentage and generate reports
  local total_students=0
  local low_attendance_count=0

  echo "Matricule,Attendance Percentage" >> "$detailed_file"
  echo "Students with Attendance < $THRESHOLD%:" >> "$summary_file"

  for matricule in "${!total_classes[@]}"; do
    total_students=$((total_students + 1))

    local attended=${attended_classes["$matricule"]:-0}
    local total=${total_classes["$matricule"]}
    local percentage=$((100 * attended / total))

    # Append to detailed file
    echo "$matricule,$percentage%" >> "$detailed_file"

    # Count students with attendance below the threshold
    if (( percentage < THRESHOLD )); then
      low_attendance_count=$((low_attendance_count + 1))
      echo "$matricule - $percentage%" >> "$summary_file"
    fi
  done

  # Append summary details
  echo "" >> "$summary_file"
  echo "Total Students: $total_students" >> "$summary_file"
  echo "Total Classes: $total_classes_count" >> "$summary_file"
  echo "Students with Attendance < $THRESHOLD%: $low_attendance_count" >> "$summary_file"
}

# Load lecturer details into associative arrays
load_lecturer_details

# Traverse all year, semester, and course folders
for year_folder in "$BASE_DIR"/*; do
  if [[ -d "$year_folder" ]]; then
    year=$(basename "$year_folder")  # Extract year (e.g., "2024-2025")

    for semester_folder in "$year_folder"/*; do
      if [[ -d "$semester_folder" ]]; then
        semester=$(basename "$semester_folder")  # Extract semester (e.g., "Semester-1")

        for course_folder in "$semester_folder"/*; do
          if [[ -d "$course_folder" ]]; then
            # Process each course folder
            calculate_course_attendance "$course_folder" "$year" "$semester"
          fi
        done
      fi
    done
  fi
done
