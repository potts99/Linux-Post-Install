#!/bin/bash

# The goal for this is to auto install docker / docker-compose 

# Test to see if user is running with root privileges.
if [[ "${UID}" -ne 0 ]]
then
 echo 'Must execute with sudo or root' >&2
 exit 1
fi

# Update your system
sudo apt update -y

# Upgrade your system
sudo apt upgrade -y

# Install packages over https
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

# Add the GPG key for the official Docker repository to your system
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add the Docker repo to your APT sources
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

# Update the package database with the new Docker Packages
sudo apt-get update -y

# Install from the Docker repo instead of the default Ubuntu repo
apt-cache policy docker-ce

# Install Docker 
sudo apt install docker-ce -y

# Add your current user to the docker group 
sudo usermod -aG docker ${USER}

# Apply the setting
su - ${USER}

# Install Docker-Compose
sudo apt-get install docker-compose -y 

# Delete the script after it has be ran
# sudo rm docker.sh

exit 0
