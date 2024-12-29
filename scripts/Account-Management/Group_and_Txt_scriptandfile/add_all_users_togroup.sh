#!/bin/bash

# Define the group name
group_name="academic_group"

# Define lecturers and students
lecturers=(
    "Dr. Alice Johnson" 
    "Prof. Bob Brown" 
    "Dr. Charlie Davis" 
    "Dr. Emily Clark" 
    "Prof. Michael Miller"
)

students=(
    "john_doe" 
    "jane_smith" 
    "alice_johnson" 
    "bob_brown" 
    "charlie_davis" 
    "emily_clark" 
    "michael_miller" 
    "sarah_wilson" 
    "james_taylor" 
    "laura_martin" 
    "david_anderson" 
    "sophia_moore" 
    "daniel_harris" 
    "olivia_thompson" 
    "matthew_white" 
    "isabella_lewis" 
    "andrew_walker" 
    "emma_hall" 
    "joseph_king" 
    "mia_scott" 
    "christopher_green" 
    "amelia_adams" 
    "joshua_nelson" 
    "elizabeth_baker" 
    "ryan_carter" 
    "grace_mitchell" 
    "lucas_perez" 
    "chloe_roberts" 
    "ethan_turner" 
    "abigail_phillips"
)

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

# Main script execution
create_group

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