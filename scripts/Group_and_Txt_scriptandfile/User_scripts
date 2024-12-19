#!/bin/bash

# Function to add students to a group
add_students_to_group() {
    local student_group="$1"
    local student_list=("$@")

    # Check if the group exists
    if ! getent group "$student_group" &>/dev/null; then
        echo "Group $student_group does not exist. Creating it..."
        sudo groupadd "$student_group"
    fi

    # Iterate over the list of student usernames and add them to the group
    echo "Adding students to group $student_group..."
    for student in "${student_list[@]:1}"; do
        # Check if the student exists
        if id "$student" &>/dev/null; then
            echo "Adding $student to group $student_group..."
            sudo usermod -aG "$student_group" "$student"
        else
            echo "Warning: User $student does not exist. Skipping..."
        fi
    done

    echo "All students have been processed."
}

# Define the group name
group_name="students"

# List of student usernames
students=(
    "john_doe" "jane_smith" "alice_johnson" "bob_brown" "charlie_davis"
    "emily_clark" "michael_miller" "sarah_wilson" "james_taylor" "laura_martin"
    "david_anderson" "sophia_moore" "daniel_harris" "olivia_thompson" "matthew_white"
    "isabella_lewis" "andrew_walker" "emma_hall" "joseph_king" "mia_scott"
    "christopher_green" "amelia_adams" "joshua_nelson" "elizabeth_baker" "ryan_carter"
    "grace_mitchell" "lucas_perez" "chloe_roberts" "ethan_turner" "abigail_phillips"
)

# Run the function to add students to the group
add_students_to_group "$group_name" "${students[@]}"
