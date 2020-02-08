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
echo "PermitEmptyPasswords no" /etc/ssh/sshd_config

# Message of the day 
sudo wget https://raw.githubusercontent.com/jwandrews99/Linux-Automation/master/misc/motd.sh
sudo mv motd.sh /etc/update-motd.d/05-info
sudo chmod +x /etc/update-motd.d/05-info

# Automatic downloads of security updates
sudo apt-get install -y unattended-upgrades
echo "Unattended-Upgrade::Allowed-Origins {
#   "${distro_id}:${distro_codename}-security";
#//  "${distro_id}:${distro_codename}-updates";
#//  "${distro_id}:${distro_codename}-proposed";
#//  "${distro_id}:${distro_codename}-backports";

#Unattended-Upgrade::Automatic-Reboot "true"; 
#}; " >> /etc/apt/apt.conf.d/50unattended-upgrades

# Fail2Ban install 
sudo apt-get install -y fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

echo "
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 4
" >> /etc/fail2ban/jail.local

# SpeedTest Install
sudo apt-get install speedtest-cli -y

# SFTP Server / FTP server that runs over ssh
echo "
Match group sftp
ChrootDirectory /home
X11Forwarding no
AllowTcpForwarding no
ForceCommand internal-sftp
" >> /etc/ssh/sshd_config

sudo service ssh restart

# Docker option install 
echo "Do you want to install docker? If so type y / If you dont want to install enter n"
read $docker

if [[ $docker == "y" ]]; then
    sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    sudo apt-get update -y
    apt-cache policy docker-ce
    sudo apt install docker-ce -y
    sudo usermod -aG docker ${USER}
    su - ${USER}
    sudo apt-get install docker-compose -y 

    echo "Congrats Docker has been installed"
    docker -v

else 
    echo "Docker was not installed"
fi

# Wireguard install
echo "Would you like to install a wireguard VPN Server? If so enter y / If you dont want to install enter n"
read $vpn

if [[ $vpn == "y" ]]; then 
    wget https://raw.githubusercontent.com/l-n-s/wireguard-install/master/wireguard-install.sh -O wireguard-install.sh
    bash wireguard-install.sh
else 
    echo "Wireguard wasnt installed"
fi

# Cleanup
sudo apt autoremove
sudo apt clean 

echo "
#############################################################

                A few tid bits

In order to use SpeedTest - Just use "speedtest" in the cli

Reboot your server to fully configure the vpn service
#############################################################
"

exit 0
