#!/bin/bash

# Output file
output_file="lecturers_users.txt"

# Define lecturers and matricules
lecturers=(
    "Dr. Alice Johnson" "Prof. Bob Brown" "Dr. Charlie Davis" "Dr. Emily Clark" "Prof. Michael Miller"
)

# Generate matricules in the format FE22Lxxx
matricules=()
for i in "${!lecturers[@]}"; do
    matricules+=("FE22L$(printf "%03d" $((i + 1)))")
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
echo "Creating lecturer users and saving details to $output_file..."

# Write header to the output file
echo "Lecturer Name, Matricule, Username, Password" > "$output_file"

# Function to create a lecturer account
create_lecturer() {
    local lecturer="$1"
    local matricule="$2"
    local username=$(echo "${lecturer}" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')  # Create username

    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "User '$username' already exists. Skipping."
        return
    fi

    # Generate password
    local password=$(generate_password "${lecturer%% *}" "$matricule")

    # Add the system user (requires sudo permissions)
    if ! sudo useradd -m -s /bin/bash -c "$lecturer" "$username"; then
        echo "Failed to create user: $username"
        return
    fi

    # Set the password for the user
    echo "$username:$password" | sudo chpasswd

    # Ensure the account is unlocked
    sudo passwd -u "$username"

    # Check if user was successfully created
    if [[ $? -eq 0 ]]; then
        # Write lecturer details to the file
        echo "$lecturer, $matricule, $username, $password" >> "$output_file"
        echo "User created: $username"
    else
        echo "Failed to create user: $username"
    fi
}

# Main script execution
if [[ $# -eq 0 ]]; then
    # Create all lecturers if no names are provided
    for i in "${!lecturers[@]}"; do
        create_lecturer "${lecturers[$i]}" "${matricules[$i]}"
    done
else
    # Create specific lecturers if names are provided
    for lecturer_name in "$@"; do
        # Find the index of the lecturer in the array
        for i in "${!lecturers[@]}"; do
            if [[ "${lecturers[$i]}" == "$lecturer_name" ]]; then
                create_lecturer "${lecturers[$i]}" "${matricules[$i]}"
                break
            fi
        done
    done
fi

echo "Lecturer user creation completed. Details saved in $output_file."