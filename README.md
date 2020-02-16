# Linux-Automation
Scripts to Automate Ubuntu / Debian Post Install

# Why 
- If you're like me and break stuff all the time, saving time by not having type out all the commands to set yout machine up post install.

- Simplicity / Save time after your install, wget the script raw and let it run.

# Time
- Post installs can take time, especially if you're trying to balance multiple things at once, run the script do something else, reply to that email and finish when its done. 

# Whats on each script?
Ubuntu / Debian post install script
```
wget https://raw.githubusercontent.com/jwandrews99/Linux-Post-Install/master/post-install.sh && bash post-install.sh
```
What this script can do:
- Sys updates 
- OpenSSH install
- Ufw config
- speedtest-cli
- Fail2Ban config
- Automatic security updates
- SSH disable root login
- SFTP server config
- Install of Wireguard VPN server - credit to https://github.com/l-n-s/wireguard-install
- Install for docker & docker compose
- Install Tor & torsocks
- Install inxi system/hardware identifier
- Install Google Cloud Platform SDK utils
- Install NodeJs
- Install Yarn
- Install Firejail sandbox
- Install Teamviewer 
- A message of the day system stats
- Install a webserver (Apache/Nginx)
- Create a nonroot user with sudo privileges
- System Clean up after the install

In order to use speedtest just use "speedtest" as the command in the cli.[ Click for more info.](https://github.com/sivel/speedtest-cli)

# To Do

Auto recongise the Os and choose the correct script to run
