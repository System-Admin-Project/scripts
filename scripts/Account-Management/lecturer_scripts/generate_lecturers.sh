#!/bin/bash

# Output log file
output_log="created_lecturers.log"
echo "Log of created lecturers" > "$output_log"

# Function to generate a lecturer ID
generate_lecturer_id() {
    local total_users=$(awk -F: '$3 >= 1000 {print $1}' /etc/passwd | wc -l)
    echo "LEC$(printf "%02d" $((total_users + 1)))"
}

# Function to generate a username
generate_username() {
    local name="$1"
    echo "${name,,}" | tr ' ' '_'
}

# Function to generate a password
generate_password() {
    local name="$1"
    local lecturer_id="$2"
    local base="${name:0:3}"  # First three letters of the name
    local lecturer_suffix="${lecturer_id:3:2}"  # Last two digits of lecturer ID
    local special_characters=("!" "@" "#" "$" "%" "^" "&" "*")
    local special="${special_characters[$RANDOM % ${#special_characters[@]}]}"
    local random_number=$(shuf -i 10-99 -n 1)  # Random number between 10 and 99
    echo "${base,,}${lecturer_suffix}${special}${random_number}"
}

# Function to create a single lecturer
create_single_lecturer() {
    read -p "Enter lecturer's full name: " name

    lecturer_id=$(generate_lecturer_id)
    username=$(generate_username "$name")
    password=$(generate_password "$name" "$lecturer_id")

    # Check if the username already exists
    if id "$username" &>/dev/null; then
        echo "User '$username' already exists. Skipping..."
        return
    fi

    # Create the user account
    if sudo useradd -m -s /bin/bash -c "$name ($lecturer_id)" "$username"; then
        echo "$username:$password" | sudo chpasswd
        sudo passwd -u "$username" &>/dev/null  # Unlock account
        echo "Lecturer created: $name, Lecturer ID: $lecturer_id, Username: $username, Password: $password" | tee -a "$output_log"
    else
        echo "Failed to create lecturer: $username" | tee -a "$output_log"
    fi
}

# Function to create lecturers from a file
create_lecturers_from_file() {
    local input_file="../Group_and_Txt_scriptandfile/lecturers_passwords.txt"

    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file '$input_file' does not exist."
        return
    fi

    # Read the input file line by line (skip the header)
    tail -n +2 "$input_file" | while IFS=',' read -r name lecturer_id username password course email; do
        # Trim whitespace
        name=$(echo "$name" | xargs)
        lecturer_id=$(echo "$lecturer_id" | xargs)
        username=$(echo "$username" | xargs)
        password=$(echo "$password" | xargs)

        # Check if the username already exists
        if id "$username" &>/dev/null; then
            echo "User '$username' already exists. Skipping..." | tee -a "$output_log"
            continue
        fi

        # Create the user account
        if sudo useradd -m -s /bin/bash -c "$name ($lecturer_id)" "$username"; then
            echo "$username:$password" | sudo chpasswd
            sudo passwd -u "$username" &>/dev/null  # Unlock account
            echo "Lecturer created: $name, Lecturer ID: $lecturer_id, Username: $username, Password: $password" | tee -a "$output_log"
        else
            echo "Failed to create lecturer: $username" | tee -a "$output_log"
        fi
    done

    echo "Lecturer creation from file completed. Check the log: $output_log"
}

# Menu for user options
while true; do
    echo
    echo "Choose an option:"
    echo "1. Add a single lecturer"
    echo "2. Add lecturers from a file"
    echo "3. Exit"
    read -p "Enter your choice (1/2/3): " choice

    case $choice in
        1)
            create_single_lecturer
            ;;
        2)
            create_lecturers_from_file
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, or 3."
            ;;
    esac
done
