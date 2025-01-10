#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo."
    exit 1
fi

# Function to restrict access to a folder
restrict_access() {
    local folder="$1"

    # Check if the folder exists
    if [[ -d "$folder" ]]; then
        # Change the ownership to root
        sudo chown root:root "$folder"
        if [[ $? -eq 0 ]]; then
            echo "Ownership of '$folder' changed to root."
        else
            echo "Error: Failed to change ownership of '$folder'."
            return
        fi

        # Restrict permissions to root only
        sudo chmod 700 "$folder"
        if [[ $? -eq 0 ]]; then
            echo "Permissions for '$folder' restricted to root only."
        else
            echo "Error: Failed to set permissions for '$folder'."
        fi
    else
        echo "Error: Folder '$folder' does not exist."
    fi
}

# Prompt the user for folder paths
echo "Enter the full paths of the folders you want to restrict, separated by spaces:"
read -r -a folder_paths

# Process each folder path
for folder in "${folder_paths[@]}"; do
    restrict_access "$folder"
done

echo "Folder access restriction process completed."
