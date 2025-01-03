#!/bin/bash

set -x  # Enable debugging (optional)

# Define the path to the student users file
students_file="../Group_and_Txt_scriptandfile/students_users.txt"

# Function to read student usernames from the file
read_students_from_file() {
    if [[ ! -f "$students_file" ]]; then
        echo "File '$students_file' not found. Exiting."
        exit 1
    fi
    # Extract the third column (username) from the file, skipping the header
    awk -F',' 'NR>1 {gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}' "$students_file"
}

# Function to delete a student account
delete_student() {
    local username="$1"

    # Kill any processes owned by the user
    if pgrep -u "$username" > /dev/null 2>&1; then
        sudo pkill -u "$username"
    fi

    # Delete the user and their home directory
    sudo userdel -r "$username" &>/dev/null

    # Check if the user was successfully deleted
    if [[ $? -eq 0 ]]; then
        echo "User deleted: $username"
    else
        echo "Failed to delete user: $username or user does not exist."
    fi

    # Check and remove leftover home directory if it exists
    if [[ -d "/home/$username" ]]; then
        sudo rm -rf "/home/$username"
        echo "Leftover home directory for '$username' removed."
    fi

    # Ensure the user is removed from /etc/passwd
    if grep -q "^$username:" /etc/passwd; then
        sudo sed -i "/^$username:/d" /etc/passwd
        echo "Removed '$username' entry from /etc/passwd."
    fi
}


# Function to delete all student accounts
delete_all_students() {
    echo "Deleting all student accounts..."
    local usernames
    usernames=$(read_students_from_file)
    for username in $usernames; do
        delete_student "$username"
    done
    echo "All student accounts deleted."
}

# Function to delete a single student by username
delete_single_student() {
    echo "Enter the username of the student you want to delete:"
    read -r username
    local usernames
    usernames=$(read_students_from_file)
    if echo "$usernames" | grep -qw "$username"; then
        delete_student "$username"
    else
        echo "User '$username' not found in the student list."
    fi
}

# Function to delete students from a file
delete_from_file() {
    echo "Enter the path to the file containing usernames to delete:"
    read -r file_path

    if [[ ! -f "$file_path" ]]; then
        echo "File '$file_path' not found. Exiting."
        return
    fi

    local usernames
    usernames=$(read_students_from_file)
    while IFS= read -r username; do
        if echo "$usernames" | grep -qw "$username"; then
            delete_student "$username"
        else
            echo "User '$username' not found in the student list."
        fi
    done < "$file_path"

    echo "Deletion from file completed."
}

# Main script execution
echo "Select an option:"
echo "1) Delete a single student"
echo "2) Delete all students"
echo "3) Delete students from a file"
read -r choice

case "$choice" in
1)
    delete_single_student
    ;;
2)
   echo "Are you sure you want to delete all student accounts? (y/n)"
read -r confirmation
if [ "$confirmation" = "y" ] || [ "$confirmation" = "Y" ]; then
    delete_all_students
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

echo "Student user deletion process completed."
