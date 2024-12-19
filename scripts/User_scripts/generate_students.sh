#!/bin/bash

# Output file
output_file="students_users.txt"

# Define students and matricules
students=(
    "Abanda Sergio" "Jane Smith" "Alice Johnson" "Bob Brown" "Charlie Davis"
    "Emily Clark" "Michael Miller" "Sarah Wilson" "James Taylor" "Laura Martin"
    "David Anderson" "Sophia Moore" "Daniel Harris" "Olivia Thompson" "Matthew White"
    "Isabella Lewis" "Andrew Walker" "Emma Hall" "Joseph King" "Mia Scott"
    "Christopher Green" "Amelia Adams" "Joshua Nelson" "Elizabeth Baker" "Ryan Carter"
    "Grace Mitchell" "Lucas Perez" "Chloe Roberts" "Ethan Turner" "Abigail Phillips"
)

# Generate matricules in the format FE22Axxx
matricules=()
for i in "${!students[@]}"; do
    matricules+=("FE22A$(printf "%03d" $((i + 1)))")
done

# Define function to generate random passwords
generate_password() {
    local name="$1"
    local matricule="$2"
    local base="${name:0:3}"  # First three letters of the first name
    local matricule_suffix="${matricule:5:2}"  # Last two digits of matricule
    local special_characters=("!" "@" "#" "$" "%" "^" "&" "*")
    local special="${special_characters[$RANDOM % ${#special_characters[@]}]}"
    local random_number=$(shuf -i 10-99 -n 1)  # Random number between 10 and 99
    echo "${base,,}${matricule_suffix}${special}${random_number}"  # Lowercase the base
}

# Start generating users
echo "Creating student users and saving details to $output_file..."

# Write header to the output file
echo "Student Name, Matricule, Username, Password" > "$output_file"

# Function to create a student account
create_student() {
    local student="$1"
    local matricule="$2"
    local username=$(echo "${student}" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')  # Create username

    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "User '$username' already exists. Skipping."
        return
    fi

    # Generate password
    local password=$(generate_password "${student%% *}" "$matricule")

    # Add the system user (requires sudo permissions)
    if ! sudo useradd -m -s /bin/bash -c "$student" "$username"; then
        echo "Failed to create user: $username"
        return
    fi

    # Set the password for the user
    echo "$username:$password" | sudo chpasswd

    # Ensure the account is unlocked
    sudo passwd -u "$username"

    # Check if user was successfully created
    if [[ $? -eq 0 ]]; then
        # Write student details to the file
        echo "$student, $matricule, $username, $password" >> "$output_file"
        echo "User created: $username"
    else
        echo "Failed to create user: $username"
    fi
}

# Main script execution
if [[ $# -eq 0 ]]; then
    # Create all students if no names are provided
    for i in "${!students[@]}"; do
        create_student "${students[$i]}" "${matricules[$i]}"
    done
else
    # Create specific students if names are provided
    for student_name in "$@"; do
        # Find the index of the student in the array
        for i in "${!students[@]}"; do
            if [[ "${students[$i]}" == "$student_name" ]]; then
                create_student "${students[$i]}" "${matricules[$i]}"
                break
            fi
        done
    done
fi

echo "Student user creation completed. Details saved in $output_file."