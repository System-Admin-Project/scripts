#!/bin/bash

# Define an array of student usernames to unlock
students=(
    "john_doe" "jane_smith" "alice_johnson" "bob_brown" "charlie_davis"
    "emily_clark" "michael_miller" "sarah_wilson" "james_taylor" "laura_martin"
    "david_anderson" "sophia_moore" "daniel_harris" "olivia_thompson" "matthew_white"
    "isabella_lewis" "andrew_walker" "emma_hall" "joseph_king" "mia_scott"
    "christopher_green" "amelia_adams" "joshua_nelson" "elizabeth_baker" "ryan_carter"
    "grace_mitchell" "lucas_perez" "chloe_roberts" "ethan_turner" "abigail_phillips"
)

# Loop through the array and unlock each user
for username in "${students[@]}"; do
    echo "Checking status for user: $username"
    
    # Check if the user is locked
    if sudo passwd -S "$username" | grep -q "L"; then
        echo "Unlocking user: $username"
        sudo passwd -u "$username"  # Unlock the user
        if [[ $? -eq 0 ]]; then
            echo "User unlocked: $username"
        else
            echo "Failed to unlock user: $username"
        fi
    else
        echo "User $username is already unlocked."
    fi
done

echo "User unlocking process completed."