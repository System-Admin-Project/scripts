#!/bin/bash

# Usage information function
usage() {
    echo "Usage: sudo $0 username [options]"
    echo "Options:"
    echo "  --name [full_name]      : Update the full name of the user."
    echo "  --password [new_pass]   : Update the password for the user."
    echo "  --shell [shell_path]    : Update the login shell for the user."
    echo "  --file [file_path]      : Update the user information in a specific file."
    exit 1
}

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo."
    exit 1
fi

# Check if at least the username argument is provided
if [ $# -lt 1 ]; then
    usage
fi

# Read the username from the first argument
username="$1"
shift

# Initialize optional parameters
full_name=""
new_password=""
shell=""
file_path=""

# Parse optional arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)
            full_name="$2"
            shift 2
            ;;
        --password)
            new_password="$2"
            shift 2
            ;;
        --shell)
            shell="$2"
            shift 2
            ;;
        --file)
            file_path="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Check if the user exists
if ! id "$username" &>/dev/null; then
    echo "Error: User '$username' does not exist."
    exit 1
fi

# Modify system user information
changes_made=0

if [ -n "$full_name" ]; then
    sudo usermod -c "$full_name" "$username"
    if [[ $? -eq 0 ]]; then
        echo "Successfully updated full name for '$username' to '$full_name'."
        changes_made=1
    else
        echo "Error: Failed to update full name for '$username'."
    fi
fi

if [ -n "$new_password" ]; then
    echo "$username:$new_password" | sudo chpasswd
    if [[ $? -eq 0 ]]; then
        echo "Successfully updated password for '$username'."
        changes_made=1
    else
        echo "Error: Failed to update password for '$username'."
    fi
fi

if [ -n "$shell" ]; then
    sudo usermod -s "$shell" "$username"
    if [[ $? -eq 0 ]]; then
        echo "Successfully updated shell for '$username' to '$shell'."
        changes_made=1
    else
        echo "Error: Failed to update shell for '$username'."
    fi
fi

# Modify file content if a file is specified
if [ -n "$file_path" ]; then
    if [[ ! -f "$file_path" ]]; then
        echo "Error: File '$file_path' not found."
        exit 1
    fi

    # Backup the file
    cp "$file_path" "$file_path.bak"
    
    # Update user information in the file
    awk -F',' -v user="$username" -v name="$full_name" -v pass="$new_password" -v shell="$shell" '
    BEGIN { OFS = FS }
    $3 == user {
        if (name != "") $1 = name
        if (pass != "") $4 = pass
        if (shell != "") $5 = shell
    }
    { print }
    ' "$file_path" > "${file_path}.tmp"

    mv "${file_path}.tmp" "$file_path"
    echo "User information updated in file '$file_path'."
    changes_made=1
fi

# Report changes or lack thereof
if [[ $changes_made -eq 0 ]]; then
    echo "No changes made for '$username'."
else
    echo "User information for '$username' updated successfully."
fi
