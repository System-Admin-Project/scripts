#!/bin/bash

# Output file
output_file="students_users.txt"

# Define students and matricules
students=(
    "John Doe" "Jane Smith" "Alice Johnson" "Bob Brown" "Charlie Davis"
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

# Loop through students and create accounts
for i in "${!students[@]}"; do
    # Extract student details
    student="${students[$i]}"
    matricule="${matricules[$i]}"
    username=$(echo "${student}" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')  # Create username

    # Generate password
    password=$(generate_password "${student%% *}" "$matricule")

    # Add the system user (requires sudo permissions)
    sudo useradd -m -s /bin/bash -c "$student" -p "$(openssl passwd -6 "$password")" "$username"

    # Check if user was successfully created
    if [[ $? -eq 0 ]]; then
        # Write student details to the file
        echo "$student, $matricule, $username, $password" >> "$output_file"
        echo "User created: $username"
    else
        echo "Failed to create user: $username"
    fi
done

echo "Student user creation completed. Details saved in $output_file."

