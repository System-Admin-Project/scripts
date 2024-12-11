#!/bin/bash

output_file="lecturers_passwords.txt"

# Define lecturers
lecturers=(
    "Dr. Vemborong" "Dr. Aline Tsague" "Dr. Nde Nguti"
    "Dr. Djouela Ines" "Dr. Achille Fumtchum" 
)

# Generate unique lecturer IDs in the format LECxx
lecturer_ids=()
for i in "${!lecturers[@]}"; do
    lecturer_ids+=("LEC$(printf "%02d" $((i + 1)))")
done

# Define function to generate random passwords
generate_password() {
    local name="$1"
    local id="$2"
    local base="${name:0:3}"  # First three letters of the first name
    local id_suffix="${id:3:2}"  # Last two digits of the lecturer ID
    local special_characters=("!" "@" "#" "$" "%" "^" "&" "*")
    local special="${special_characters[$RANDOM % ${#special_characters[@]}]}"
    local random_number=$(shuf -i 10-99 -n 1)  # Random number between 10 and 99
    echo "${base,,}${id_suffix}${special}${random_number}"  # Lowercase the base
}

# Start generating users
echo "Creating lecturer users and saving details to $output_file..."

# Write header to the output file
echo "Lecturer Name, Lecturer ID, Username, Password" > "$output_file"

# Loop through lecturers and create accounts
for i in "${!lecturers[@]}"; do
    # Extract lecturer details
    lecturer="${lecturers[$i]}"
    lecturer_id="${lecturer_ids[$i]}"
    username=$(echo "${lecturer}" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')  # Create username

    # Generate password
    password=$(generate_password "${lecturer%% *}" "$lecturer_id")

    # Add the system user (requires sudo permissions)
    sudo useradd -m -s /bin/bash -c "$lecturer" -p "$(openssl passwd -6 "$password")" "$username"

    # Check if user was successfully created
    if [[ $? -eq 0 ]]; then
        # Write lecturer details to the file
        echo "$lecturer, $lecturer_id, $username, $password" >> "$output_file"
        echo "User created: $username"
    else
        echo "Failed to create user: $username"
    fi
done

echo "Lecturer user creation completed. Details saved in $output_file."

