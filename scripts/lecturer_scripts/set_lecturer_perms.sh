#!/bin/bash

# Function to set folder permissions
set_folder_permissions() {
    local lecturer_name="$1"
    local folder_path="$2"
    local student_group="$3"

    # Check if lecturer username is provided
    if [ -z "$lecturer_name" ]; then
        echo "Error: No lecturer username provided."
        exit 1
    fi

    # Check if folder path is provided
    if [ -z "$folder_path" ]; then
        echo "Error: No folder path provided."
        exit 1
    fi

    # Check if student group is provided
    if [ -z "$student_group" ]; then
        echo "Error: No student group provided."
        exit 1
    fi

    # Check if the lecturer exists on the system
    if ! id "$lecturer_name" &>/dev/null; then
        echo "Error: User $lecturer_name does not exist."
        exit 1
    fi

    # Check if the student group exists
    if ! getent group "$student_group" &>/dev/null; then
        echo "Error: Group $student_group does not exist."
        exit 1
    fi

    # Check if the folder exists
    if [ ! -d "$folder_path" ]; then
        echo "Error: Folder $folder_path does not exist."
        exit 1
    fi

    # Set ownership of the folder to the lecturer and the student group
    echo "Setting ownership of the folder to $lecturer_name and group $student_group..."
    sudo chown -R "$lecturer_name:$student_group" "$folder_path"

    # Set permissions:
    # Lecturer: Full permissions (read, write, execute) = 7
    # Students: Read and execute (view only) = 5
    echo "Setting permissions..."
    sudo chmod -R 750 "$folder_path"

    # Verify the changes
    echo "Folder details:"
    ls -ld "$folder_path"
    
    echo "Permissions for $folder_path have been set: Lecturer can edit, students can view."
}

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root or with sudo privileges."
    exit 1
fi

# Prompt user for lecturer username
read -p "Enter the lecturer's username: " lecturer_name

# Prompt user for folder path
read -p "Enter the path to the folder you want to modify permissions for: " folder_path

# Prompt user for student group name
read -p "Enter the student group name: " student_group

# Call the function to set permissions
set_folder_permissions "$lecturer_name" "$folder_path" "$student_group"