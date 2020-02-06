#!/bin/bash

# Goal: Script which automatically sets up a new Ubuntu Machine after installation

# Test to see if user is running with root privileges.
if [[ "${UID}" -ne 0 ]]
then
 echo 'Must execute with sudo or root' >&2
 exit 1
fi

# Ensure system is up to date
sudo apt-get update -y 

# Upgrade the system
sudo apt-get update -y

# Install OpenSSH
sudo apt-get openssh-server -y

# Enable Firewall
sudo ufw enable 

# configure the firewall 
sudo ufw allow OpenSSH

# Check exit code
if [[ "${?}" -n0 0 ]]
then 
 echo "Failed to Ubuntu" >&2
 exit 1
fi

exit 0
