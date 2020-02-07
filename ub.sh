#!/bin/bash

# Goal: Script which automatically sets up a new Ubuntu Machine after installation
# This is a basic install, easily configurable to your needs

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

# Message of the day 
sudo wget https://raw.githubusercontent.com/jwandrews99/Linux-Automation/master/motd.sh
sudo mv motd.sh /etc/update-motd.d/05-info
sudo chmod +x /etc/update-motd.d/05-info

# Automatic downloads of updates
# sudo apt-get install -y unattended-upgrades
# echo "Unattended-Upgrade::Allowed-Origins {
#   "${distro_id}:${distro_codename}-security";
#//  "${distro_id}:${distro_codename}-updates";
#//  "${distro_id}:${distro_codename}-proposed";
#//  "${distro_id}:${distro_codename}-backports";

#Unattended-Upgrade::Automatic-Reboot "true"; 
#}; " >> /etc/apt/apt.conf.d/50unattended-upgrades



exit 0
