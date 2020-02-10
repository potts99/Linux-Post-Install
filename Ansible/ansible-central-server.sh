#!/bin/bash

# Goal = To automate the install of ainsible on a Ubuntu server 
# Test to see if user is running with root privileges.
if [[ "${UID}" -ne 0 ]]
then
 echo 'Must execute with sudo or root' >&2
 exit 1
fi

# Ensure system is up to date
sudo apt-get update -y 

# Upgrade the system
sudo apt-get upgrade -y

# Install OpenSSH
sudo apt-get install openssh-server -y

# Enable Firewall
sudo ufw enable 

# configure the firewall
sudo ufw allow OpenSSH

# Disabling root login 
echo "PermitRootLogin no" >> /etc/ssh/sshd_config 

# Install Ansible 
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible
echo "Default config files are found in /etc/ansible"

# Basic file setup 
mkdir Playbooks
mkdir Tasks
mkdir Handlers
mkdir Roles 




exit 0