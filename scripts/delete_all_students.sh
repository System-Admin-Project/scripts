#!/bin/bash
set -x

# Define an array of student usernames to delete
students=(
    "john_doe" "jane_smith" "alice_johnson" "bob_brown" "charlie_davis"
    "emily_clark" "michael_miller" "sarah_wilson" "james_taylor" "laura_martin"
    "david_anderson" "sophia_moore" "daniel_harris" "olivia_thompson" "matthew_white"
    "isabella_lewis" "andrew_walker" "emma_hall" "joseph_king" "mia_scott"
    "christopher_green" "amelia_adams" "joshua_nelson" "elizabeth_baker" "ryan_carter"
    "grace_mitchell" "lucas_perez" "chloe_roberts" "ethan_turner" "abigail_phillips"
)

# Loop through the array and delete each user
for username in "${students[@]}"; do
    # Delete the user and their home directory
    sudo userdel "$username"
    
    # Check if the user was successfully deleted
    if [[ $? -eq 0 ]]; then
        echo "User deleted: $username"
    else
        echo "Failed to delete user: $username"
    fi
done

echo "Student user deletion completed."