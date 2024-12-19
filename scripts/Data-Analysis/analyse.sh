#!/bin/bash

#Get the total number of students offering the course
#Get the students with attendance less than 70%
#Get the total number of classes
#Individualised-reports
#Daily-Weekly-Monthly?

# Base directory where attendance CSV files are stored
BASE_DIR="../../data/FET/Level400/SoftwareEng/Attendance/"


# Output summary file
SUMMARY_FILE="course_attendance_summary.txt"

# Initialize the summary file
echo "Course Attendance Summary" > "$SUMMARY_FILE"
echo "==========================" >> "$SUMMARY_FILE"

# Function to calculate attendance for all students in a course
calculate_course_attendance() {
  local course_folder=$1

  # Declare associative arrays to track attendance
  declare -A total_classes
  declare -A attended_classes

  # Loop through CSV files in the course folder
  for file in "$course_folder"/*.csv; do
    if [[ -f "$file" ]]; then
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

  # Calculate attendance percentage for each student
  for matricule in "${!total_classes[@]}"; do
    local percentage=$((100 * attended_classes["$matricule"] / total_classes["$matricule"]))
    echo "$matricule,$percentage%"
  done
}

# Iterate through each course folder
for course_folder in "$BASE_DIR"/*; do
  if [[ -d "$course_folder" ]]; then
    course_name=$(basename "$course_folder")
    echo "Course: $course_name" >> "$SUMMARY_FILE"
    echo "-----------------" >> "$SUMMARY_FILE"

    # Calculate attendance for the course
    calculate_course_attendance "$course_folder" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE" # Add spacing for readability
  fi
done

# Display the summary
cat "$SUMMARY_FILE"
