#!/bin/bash

# Base directory where attendance CSV files are stored
BASE_DIR="../../data/FET/Level400/SoftwareEng/Attendance/2024-2025/Semester-1"
THRESHOLD=70

# Function to calculate attendance for all students in a course
calculate_course_attendance() {
  local course_folder=$1
  local course_name=$(basename "$course_folder")

  # Declare associative arrays to track attendance
  declare -A total_classes
  declare -A attended_classes

  # Create output directories
  local output_folder="./Reports/$course_name"
  mkdir -p "$output_folder"

  local detailed_file="$output_folder/${course_name}_detailed.txt"
  local summary_file="$output_folder/${course_name}_summary.txt"

  # Initialize files
  echo "Detailed Attendance Report for $course_name" > "$detailed_file"
  echo "===============================" >> "$detailed_file"
  echo "Summary Report for $course_name" > "$summary_file"
  echo "===============================" >> "$summary_file"

  # Include lecturer's name and email in the summary file
  local lecturer_name="Dr. John Doe"
  local lecturer_email="johndoe@example.com"
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
  echo "Students with Attendance < 70%:" >> "$summary_file"

  for matricule in "${!total_classes[@]}"; do
    total_students=$((total_students + 1))

    local attended=${attended_classes["$matricule"]:-0}
    local total=${total_classes["$matricule"]}
    local percentage=$((100 * attended / total))

    # Append to detailed file
    echo "$matricule,$percentage%" >> "$detailed_file"

    # Count students with attendance below 70%
    if (( percentage < THRESHOLD )); then
      low_attendance_count=$((low_attendance_count + 1))
      echo "$matricule - $percentage%" >> "$summary_file"
    fi
  done

  # Append summary details
  echo "" >> "$summary_file"
  echo "Total Students: $total_students" >> "$summary_file"
  echo "Total Classes: $total_classes_count" >> "$summary_file"
  echo "Students with Attendance < 70%: $low_attendance_count" >> "$summary_file"
}

# Iterate through each course folder
for course_folder in "$BASE_DIR"/*; do
  if [[ -d "$course_folder" ]]; then
    calculate_course_attendance "$course_folder"
  fi
done
