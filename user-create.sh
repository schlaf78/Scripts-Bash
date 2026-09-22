#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Run this script as root."
    exit 1
fi

read -rp "Enter username: " USERNAME

if [ -z "$USERNAME" ]; then
    echo "ERROR: Username cannot be empty."
    exit 1
fi

if ! [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "ERROR: Invalid username."
    echo "Use lowercase letters, numbers, underscore or hyphen."
    exit 1
fi

if id "$USERNAME" &>/dev/null; then
    echo "ERROR: User '$USERNAME' already exists."
    exit 1
fi

SUDO_FILE="/etc/sudoers.d/${USERNAME}"

# Generate random 16-character password
PASSWORD=$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 16)

echo
echo "Creating user: $USERNAME"

useradd \
    --create-home \
    --shell /bin/bash \
    "$USERNAME"

echo "${USERNAME}:${PASSWORD}" | chpasswd

echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > "$SUDO_FILE"

chmod 0440 "$SUDO_FILE"
chown root:root "$SUDO_FILE"

if ! visudo -cf "$SUDO_FILE"; then
    echo "ERROR: Invalid sudoers configuration."
    rm -f "$SUDO_FILE"
    userdel -r "$USERNAME"
    exit 1
fi

echo
echo "========================================"
echo " User successfully created"
echo "========================================"
echo "Username : $USERNAME"
echo "Password : $PASSWORD"
echo "Home     : /home/$USERNAME"
echo "Shell    : /bin/bash"
echo "Sudo     : NOPASSWD: ALL"
echo "========================================"
echo
echo "Test:"
echo "  su - $USERNAME"
echo "  sudo -i"