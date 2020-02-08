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
sudo wget https://raw.githubusercontent.com/jwandrews99/Linux-Automation/master/misc/motd.sh
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

echo "
########################

In order to use type: speedtest-cli and press enter

########################"

# vsftpd for ftp server
sudo apt install vsftpd -y 
sudo rm /etc/vsftpd.conf # So we can start a fresh config
cd /etc/
sudo wget https://raw.githubusercontent.com/jwandrews99/Linux-Automation/master/misc/vsftpd.conf
cd

# Configure firewall
sudo ufw allow 20/tcp
sudo ufw allow 21/tcp 
sudo ufw allow 990/tcp
sudo ufw allow 40000:50000/tcp # Range of passive ports 

sudo mkdir /{$USER}/ftpmain/ftp
sudo chown nobody:nogroup /home/{$USER}/ftp #sets ownership 
sudo mkdir /home/{$USER}/ftp/files
sudo chown {$USER}:{$USER} /home/{$USER}/ftp/files
echo "vsftpd test file" >> /home/{$USER}/ftp/files/test.txt

echo "{$USER}" >> -a /etc/vsftpd.userlist

sudo systemctl restart vsftpd

# Securing FTP with TLS/SSL
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem

sudo systemctl restart vsftpd


exit 0
