#!/bin/bash
#To run => sudo ./modify_user.sh username "New Full Name" /bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 username [full_name] [shell]"
    echo "  username   : The username of the account to modify."
    echo "  full_name  : (Optional) The new full name for the user."
    echo "  shell      : (Optional) The new shell for the user (e.g., /bin/bash)."
    exit 1
}

# Check if at least one argument (username) is provided
if [ $# -lt 1 ]; then
    usage
fi

# Read the username from the first argument
username=$1

# Check if the user exists
if ! id "$username" &>/dev/null; then
    echo "User $username does not exist."
    exit 1
fi

# Prepare variables for optional parameters
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
if [ -n "$full_name" ]; then
    sudo usermod -c "$full_name" "$username"
    echo "Updated full name for $username to '$full_name'."
fi

if [ -n "$shell" ]; then
    sudo usermod -s "$shell" "$username"
    echo "Updated shell for $username to '$shell'."
fi

# Check if any changes were made
if [ -z "$full_name" ] && [ -z "$shell" ]; then
    echo "No changes made for $username."
else
    echo "User information for $username updated successfully."
fi