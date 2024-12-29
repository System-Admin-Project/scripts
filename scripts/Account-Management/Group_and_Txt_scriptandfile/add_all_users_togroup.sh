#!/bin/bash

# Define the group name
group_name="academic_group"

# File paths for lecturers and students
lecturers_file="../Group_and_Txt_scriptand file/lecturers_passwords.txt"
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

# Function to read users from a file
read_users_from_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        mapfile -t users < "$file"
        echo "${users[@]}"
    else
        echo "Error: File '$file' not found." >&2
        exit 1
    fi
}

# Main script execution
create_group

# Read lecturers and students from the files
lecturers=($(read_users_from_file "$lecturers_file"))
students=($(read_users_from_file "$students_file"))

if [[ $# -eq 0 ]]; then
    # No arguments provided, add all lecturers and students
    for lecturer in "${lecturers[@]}"; do
        add_user_to_group "$lecturer"
    done

    for student in "${students[@]}"; do
        add_user_to_group "$student"
    done
else
    # Add specified user(s)
    for user in "$@"; do
        add_user_to_group "$user"
    done
fi

echo "User addition process completed."
