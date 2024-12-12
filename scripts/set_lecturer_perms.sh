#!/bin/bash

# Function to assign permissions to an existing folder
assign_lecturer_permissions() {
    # Accept lecturer name and folder path as arguments
    local lecturer_name="$1"
    local folder_path="$2"
    
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

    # Check if the lecturer exists on the system
    if ! id "$lecturer_name" &>/dev/null; then
        echo "Error: User $lecturer_name does not exist."
        exit 1
    fi

    # Check if the folder exists
    if [ ! -d "$folder_path" ]; then
        echo "Error: Folder $folder_path does not exist."
        exit 1
    fi

    # Check if the folder already has the correct permissions
    current_permissions=$(stat -c "%a" "$folder_path")
    if [ "$current_permissions" == "700" ]; then
        echo "Permissions for $folder_path are already set to 700. No changes made."
        exit 0
    fi

    # Set ownership of the folder to the lecturer
    echo "Setting ownership of the folder to $lecturer_name..."
    sudo chown -R "$lecturer_name:$lecturer_name" "$folder_path"

    # Set permissions so only the lecturer has access (700)
    echo "Setting permissions to 700 for exclusive access..."
    sudo chmod -R 700 "$folder_path"

    # Verify the changes
    echo "Folder details:"
    ls -ld "$folder_path"
    
    echo "Permissions for $folder_path have been set so that only $lecturer_name has access."
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

# Call function to assign permissions
assign_lecturer_permissions "$lecturer_name" "$folder_path"

