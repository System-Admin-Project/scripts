#!/bin/bash

# File containing lecturer information
lecturers_file="../Group_and_Txt_scriptandfile/lecturers_passwords.txt"

# Log file for deleted lecturers
output_file="deleted_lecturers.log"

# Ensure the log file exists
echo "Deleted Lecturer Username, Deletion Time" > "$output_file"

# Function to read lecturer usernames from the file
read_lecturers_from_file() {
    if [[ ! -f "$lecturers_file" ]]; then
        echo "File '$lecturers_file' not found. Exiting."
        exit 1
    fi
    awk -F',' 'NR>1 {gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}' "$lecturers_file"
}

# Function to delete a lecturer account
delete_lecturer() {
    local username="$1"

    # Check if the user exists
    if id "$username" &>/dev/null; then
        echo "Are you sure you want to delete the user '$username'? (y/n)"
        read -r confirmation

        if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then
            # Delete the user and their home directory
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

# Function to delete all lecturer accounts
delete_all_lecturers() {
    echo "Deleting all lecturer accounts..."
    local usernames
    usernames=$(read_lecturers_from_file)
    for username in $usernames; do
        delete_lecturer "$username"
    done
    echo "All lecturer accounts deleted."
}

# Function to delete a single lecturer account
delete_single_lecturer() {
    echo "Enter the username of the lecturer you want to delete:"
    read -r username
    local usernames
    usernames=$(read_lecturers_from_file)
    if echo "$usernames" | grep -qw "$username"; then
        delete_lecturer "$username"
    else
        echo "User '$username' not found in the lecturer list."
    fi
}

# Function to delete lecturers from a file
delete_from_file() {
    echo "Enter the path to the file containing usernames to delete:"
    read -r file_path

    if [[ ! -f "$file_path" ]]; then
        echo "File '$file_path' not found. Exiting."
        return
    fi

    local usernames
    usernames=$(read_lecturers_from_file)
    while IFS= read -r username; do
        if echo "$usernames" | grep -qw "$username"; then
            delete_lecturer "$username"
        else
            echo "User '$username' not found in the lecturer list."
        fi
    done < "$file_path"

    echo "Deletion from file completed."
}

# Main script execution
echo "Select an option:"
echo "1) Delete a single lecturer"
echo "2) Delete all lecturers"
echo "3) Delete lecturers from a file"
read -r choice

case "$choice" in
1)
    delete_single_lecturer
    ;;
2)
    echo "Are you sure you want to delete all lecturer accounts? (y/n)"
    read -r confirmation
    if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then
        delete_all_lecturers
    else
        echo "Operation canceled. No accounts deleted."
    fi
    ;;
3)
    delete_from_file
    ;;
*)
    echo "Invalid choice. Exiting."
    ;;
esac

echo "Lecturer user deletion process completed. Check '$output_file' for details."
