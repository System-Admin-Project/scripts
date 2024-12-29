#!/bin/bash

# Usage information function
usage() {
    echo "Usage: sudo $0 username [full_name] [shell]"
    echo "  username   : The username of the account to modify."
    echo "  full_name  : (Optional) The new full name for the user."
    echo "  shell      : (Optional) The new shell for the user (e.g., /bin/bash)."
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

# Check if the user exists
if ! id "$username" &>/dev/null; then
    echo "Error: User '$username' does not exist."
    exit 1
fi

# Initialize optional parameters
full_name=""
shell=""

# Parse optional parameters
if [ $# -ge 2 ]; then
    full_name="$2"
fi

if [ $# -ge 3 ]; then
    shell="$3"
fi

# Modify user information
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

if [ -n "$shell" ]; then
    sudo usermod -s "$shell" "$username"
    if [[ $? -eq 0 ]]; then
        echo "Successfully updated shell for '$username' to '$shell'."
        changes_made=1
    else
        echo "Error: Failed to update shell for '$username'."
    fi
fi

# Report changes or lack thereof
if [[ $changes_made -eq 0 ]]; then
    echo "No changes made for '$username'."
else
    echo "User information for '$username' updated successfully."
fi
