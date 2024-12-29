#!/bin/bash

# Base directory where attendance reports are stored
REPORTS_DIR="../Data-Analysis/Reports"

# Email function to send detailed and summary reports
send_email_to_lecturer() {
  local course_name=$1
  local lecturer_email=$2
  local detailed_file=$3
  local summary_file=$4

  # Email subject and body
  local subject="Attendance Reports for $course_name"
  local body="Dear Lecturer,Please find attached the detailed and summary attendance reports for $course_name.Best regards,Attendance System"

  # Send email with attachments using msmtp
  (echo "Subject: $subject";
   echo "To: $lecturer_email";
   echo "Content-Type: multipart/mixed; boundary=boundary";
   echo "";
   echo "--boundary";
   echo "Content-Type: text/plain";
   echo "";
   echo "$body";
   echo "";
   echo "--boundary";
   echo "Content-Type: text/plain; name=$(basename "$detailed_file")";
   echo "Content-Disposition: attachment; filename=$(basename "$detailed_file")";
   echo "";
   cat "$detailed_file";
   echo "";
   echo "--boundary";
   echo "Content-Type: text/plain; name=$(basename "$summary_file")";
   echo "Content-Disposition: attachment; filename=$(basename "$summary_file")";
   echo "";
   cat "$summary_file";
   echo "";
   echo "--boundary--") | msmtp "$lecturer_email"

  if [[ $? -eq 0 ]]; then
    echo "Email sent to $lecturer_email for $course_name."
  else
    echo "Failed to send email to $lecturer_email for $course_name."
  fi
}

# Iterate through each course folder in the reports directory
for course_folder in "$REPORTS_DIR"/*; do
  if [[ -d "$course_folder" ]]; then
    # Extract course name and lecturer information
    course_name=$(basename "$course_folder")
    summary_file="$course_folder/${course_name}_summary.txt"

    # Retrieve lecturer's email from the summary file
    lecturer_email=$(grep -i "Email:" "$summary_file" | awk -F': ' '{print $2}')
    detailed_file="$course_folder/${course_name}_detailed.txt"

    # Check if the required files exist
    if [[ -f "$detailed_file" && -f "$summary_file" && -n "$lecturer_email" ]]; then
      send_email_to_lecturer "$course_name" "$lecturer_email" "$detailed_file" "$summary_file"
    else
      echo "Missing required files or email for $course_name. Skipping."
    fi
  fi
done
