#!/bin/bash
set -x

# Define an array of student usernames
students=(
    "john_doe" "jane_smith" "alice_johnson" "bob_brown" "charlie_davis"
    "emily_clark" "michael_miller" "sarah_wilson" "james_taylor" "laura_martin"
    "david_anderson" "sophia_moore" "daniel_harris" "olivia_thompson" "matthew_white"
    "isabella_lewis" "andrew_walker" "emma_hall" "joseph_king" "mia_scott"
    "christopher_green" "amelia_adams" "joshua_nelson" "elizabeth_baker" "ryan_carter"
    "grace_mitchell" "lucas_perez" "chloe_roberts" "ethan_turner" "abigail_phillips"
)

# Function to delete a student account
delete_student() {
    local username="$1"

    # Delete the user and their home directory
    sudo userdel -r "$username"
    
    # Check if the user was successfully deleted
    if [[ $? -eq 0 ]]; then
        echo "User deleted: $username"
    else
        echo "Failed to delete user: $username"
    fi
}

# Main script execution
if [[ $# -eq 0 ]]; then
    echo "No student names provided. This will delete all student accounts!"
    echo "Are you sure you want to proceed? (y/n)"
    read -r confirmation

    if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
        echo "Operation canceled. No accounts deleted."
        exit 0
    fi

    # Delete all student accounts
    echo "Deleting all student accounts..."
    for username in "${students[@]}"; do
        delete_student "$username"
    done
else
    # Loop through all provided usernames
    for student_username in "$@"; do
        if [[ " ${students[@]} " =~ " ${student_username} " ]]; then
            delete_student "$student_username"
        else
            echo "User '$student_username' not found in the student list."
        fi
    done
fi

echo "Student user deletion completed."