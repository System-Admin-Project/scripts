#!/bin/bash

# Output log file
output_log="created_students.log"
echo "Log of created users" > "$output_log"

# Function to generate a matricule
generate_matricule() {
    local total_users=$(awk -F: '$3 >= 1000 {print $1}' /etc/passwd | wc -l)
    echo "FE22A$(printf "%03d" $((total_users + 1)))"
}

# Function to generate a username
generate_username() {
    local name="$1"
    echo "${name,,}" | tr ' ' '_'  # Convert to lowercase and replace spaces with underscores
}

# Function to generate a password
generate_password() {
    local name="$1"
    local matricule="$2"
    local base="${name:0:3}"  # First three letters of the name
    local matricule_suffix="${matricule:5:2}"  # Last two digits of matricule
    local special_characters=("!" "@" "#" "$" "%" "^" "&" "*")
    local special="${special_characters[$RANDOM % ${#special_characters[@]}]}"
    local random_number=$(shuf -i 10-99 -n 1)  # Random number between 10 and 99
    echo "${base,,}${matricule_suffix}${special}${random_number}"  # Lowercase the base
}

# Function to create a single user
create_single_user() {
    read -p "Enter student's full name: " name
    read -p "Enter student's age: " age
    read -p "Enter student's DOB (YYYY-MM-DD): " dob

    matricule=$(generate_matricule)
    username=$(generate_username "$name")
    password=$(generate_password "$name" "$matricule")

    # Check if the username already exists
    if id "$username" &>/dev/null; then
        echo "User '$username' already exists. Skipping..."
        return
    fi

    # Create the user account
    if sudo useradd -m -s /bin/bash -c "$name ($matricule)" "$username"; then
        echo "$username:$password" | sudo chpasswd
        sudo passwd -u "$username" &>/dev/null  # Unlock account
        echo "User created: $name, Matricule: $matricule, Username: $username, Password: $password" | tee -a "$output_log"
    else
        echo "Failed to create user: $username" | tee -a "$output_log"
    fi
}

# Function to create users from a file
create_users_from_file() {
    local input_file="../Group_and_Txt_scriptandfile/students_users.txt"

    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file '$input_file' does not exist."
        return
    fi

    # Read the input file line by line (skip the header)
    tail -n +2 "$input_file" | while IFS=',' read -r name matricule username password dob age; do
        # Trim whitespace
        name=$(echo "$name" | xargs)
        matricule=$(echo "$matricule" | xargs)
        username=$(echo "$username" | xargs)
        password=$(echo "$password" | xargs)

        # Check if the username already exists
        if id "$username" &>/dev/null; then
            echo "User '$username' already exists. Skipping..." | tee -a "$output_log"
            continue
        fi

        # Create the user account
        if sudo useradd -m -s /bin/bash -c "$name ($matricule)" "$username"; then
            echo "$username:$password" | sudo chpasswd
            sudo passwd -u "$username" &>/dev/null  # Unlock account
            echo "User created: $name, Matricule: $matricule, Username: $username, Password: $password" | tee -a "$output_log"
        else
            echo "Failed to create user: $username" | tee -a "$output_log"
        fi
    done

    echo "User creation from file completed. Check the log: $output_log"
}

# Menu for user options
while true; do
    echo
    echo "Choose an option:"
    echo "1. Add a single student"
    echo "2. Add students from a file"
    echo "3. Exit"
    read -p "Enter your choice (1/2/3): " choice

    case $choice in
        1)
            create_single_user
            ;;
        2)
            create_users_from_file
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
