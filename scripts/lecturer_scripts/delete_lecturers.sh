#!/bin/bash

# Output file for logging deletions
output_file="deleted_lecturers.log"

# Ensure the output file exists
echo "Deleted Lecturer Username, Deletion Time" > "$output_file"

# Function to delete a lecturer account
delete_lecturer() {
    local username="$1"

    # Check if the user exists
    if id "$username" &>/dev/null; then
        echo "Are you sure you want to delete the user '$username'? (y/n)"
        read -r confirmation

        if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then
            # Delete the user and optionally their home directory
            sudo userdel -r "$username"
            echo "User '$username' has been deleted."
            echo "$username, $(date)" >> "$output_file"
        else
            echo "Deletion of user '$username' canceled."
        fi
    else
        echo "User '$username' does not exist."
    fi
}

# Main script execution
if [[ $# -eq 0 ]]; then
    echo "No lecturer names provided. This will delete all lecturer accounts!"
    echo "Are you sure you want to proceed? (y/n)"
    read -r confirmation

    if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
        echo "Operation canceled. No accounts deleted."
        exit 0
    fi

    # Delete all lecturer accounts
    echo "Deleting all lecturer accounts..."
    for username in $(getent passwd | grep -E 'lecturer_prefix' | cut -d: -f1); do
        delete_lecturer "$username"
    done
else
    # Loop through all provided usernames
    for lecturer_username in "$@"; do
        delete_lecturer "$lecturer_username"
    done
fi

echo "Deletion process completed. Check '$output_file' for details."