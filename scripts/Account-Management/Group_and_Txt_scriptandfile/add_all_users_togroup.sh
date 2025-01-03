#!/bin/bash

# Define the group name
group_name="academic_group"

# File paths for lecturers and students
lecturers_file="../Group_and_Txt_scriptandfile/lecturers_passwords.txt"
students_file="../Group_and_Txt_scriptandfile/students_users.txt"

# Function to create a group if it doesn't exist
create_group() {
    if ! getent group "$group_name" > /dev/null; then
        sudo groupadd "$group_name"
        echo "Group '$group_name' created."
    else
        echo "Group '$group_name' already exists."
    fi
}

# Function to add a user to the group
add_user_to_group() {
    local user="$1"
    if id "$user" &>/dev/null; then
        sudo usermod -aG "$group_name" "$user"
        echo "User '$user' added to group '$group_name'."
    else
        echo "User '$user' does not exist. Skipping."
    fi
}

# Function to read usernames from a file
read_usernames_from_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        awk -F',' 'NR > 1 {gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}' "$file"
    else
        echo "Error: File '$file' not found." >&2
        exit 1
    fi
}

# Main script execution
create_group

# Read usernames from the files
lecturers=$(read_usernames_from_file "$lecturers_file")
students=$(read_usernames_from_file "$students_file")

# Add all lecturers to the group
echo "Adding lecturers to group '$group_name'..."
while IFS= read -r lecturer; do
    add_user_to_group "$lecturer"
done <<< "$lecturers"

# Add all students to the group
echo "Adding students to group '$group_name'..."
while IFS= read -r student; do
    add_user_to_group "$student"
done <<< "$students"

echo "User addition process completed."
