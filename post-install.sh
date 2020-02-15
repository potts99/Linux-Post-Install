#!/bin/bash

# Goal: Script which automatically sets up a new Ubuntu Machine after installation
# This is a basic install, easily configurable to your needs

## Add some color

ANSI_RED=$'\033[1;31m'
ANSI_YEL=$'\033[1;33m'
ANSI_GRN=$'\033[1;32m'
ANSI_VIO=$'\033[1;35m'
ANSI_BLU=$'\033[1;36m'
ANSI_WHT=$'\033[1;37m'
ANSI_RST=$'\033[0m'

echo_cmd()    { echo -e "${ANSI_BLU}${@}${ANSI_RST}"; }
echo_note()   { echo -e "${ANSI_YEL}${@}${ANSI_RST}"; }
echo_info()   { echo -e "${ANSI_GRN}${@}${ANSI_RST}"; }
echo_prompt() { echo -e "${ANSI_WHT}${@}${ANSI_RST}"; }
echo_warn()   { echo -e "${ANSI_YEL}${@}${ANSI_RST}"; }
echo_debug()  { echo -e "${ANSI_VIO}${@}${ANSI_RST}"; }
echo_fail()   { echo -e "${ANSI_RED}${@}${ANSI_RST}"; }


## Add your favorite/commonly used packages available from the system's package maanger here:
general_linuxpkgs() {
    sudo DEBIAN_FRONTEND=noninteractive apt install htop git apt-transport-https zip unzip netcat nano wdiff -y
}


## App installing functions

install_teamviewer() {
    echo_info " *** installing Teamviewer for Linux *** "
    cd ~/Downloads
    wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
    sudo gdebi -n teamviewer_amd64.deb
}

install_tor() {
    echo_info "Installing Tor"
    source /etc/os-release
    echo "deb https://deb.torproject.org/torproject.org $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/onions.list
    sudo bash -c 'curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import'
    sudo bash -c 'gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -'
    sudo apt update
    sudo apt install -y tor deb.torproject.org-keyring torsocks
}

install_micahs() {
    echo_info " *** Installing Micah F Lee's repository from github.com/micahflee; includes Onionshare and Torbrowser-launcher"
    sudo DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:micahflee/ppa --yes
    sudo apt update
    sudo apt install -y onionshare torbrowser-launcher
}

install_node() {
    echo_info " ** Installing NodeJS 12 and npm node package manager ** "
    cd ;
    sudo apt install gcc g++ make -y
    curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
    sudo -v
    sudo apt update
    sudo apt install -y nodejs
}

local_globalnode() {
    mkdir $HOME/.npm-global
    npm config set prefix "$HOME/.npm-global"
    echo "export PATH=$HOME/.npm-global/bin:$PATH" | tee -a $HOME/.profile
    source $HOME/.profile
    npm install npm@latest -g
}

install_yarn() {
    echo_info "Installing Yarn: node package manager"
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo DEBIAN_FRONTEND=noninteractive apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get update && sudo apt-get install -y yarn
}

install_firejail() {
    echo_info "Installing Firejail: Linux SUID Sandbox"
    wget https://sourceforge.net/projects/firejail/files/LTS/firejail-apparmor_0.9.56.2-LTS_1_amd64.deb
    sudo gdebi -n firejail-apparmor_0.9.56.2-LTS_1_amd64.deb
}

install_dockerce() {
    echo_info "Installing Docker-CE + Portainer on port 9000"
    sudo apt remove docker docker-engine docker.io containerd runc -y
    sudo apt update && sudo apt -y full-upgrade
    sudo apt install apt-transport-https ca-certificates curl software-properties-common gnupg-agent -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo DEBIAN_FRONTEND=noninteractive add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io -y

    echo_info " 
    
        Installing Portainer on port 9000

    "

    sudo docker volume create portainer_data
    sudo docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

    echo_note "
#####################################################################################################    
                            Congrats Docker has been installed
######################################################################################################
"
    docker -v
}

install_dockercompose() {
    if [[ -z $(which docker) ]]; then
        echo_warn "Need To install Docker first "
        install_dockerce
    fi
    sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose 
    sudo chmod +x /usr/local/bin/docker-compose 
    sudo docker-compose --version 
}


install_inxi() {
    echo_info " Installing Inxi (System/Hardware Identifier) "
    wget -O inxi https://github.com/smxi/inxi/raw/master/inxi
    chmod +x inxi 
    sudo mv inxi /usr/local/bin/inxi
    sudo chown root:root /usr/local/bin/inxi
}

install_googlecloudSDK() {
    echo_info " ** installing Google Cloud Platform SDK commandline tools ** "
    cd ; export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" 
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo DEBIAN_FRONTEND=noninteractive apt-key add - 
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    sudo -v
    sudo apt update 
    sudo apt install -y google-cloud-sdk
}

apparmor_grub() {
    echo_info " ** Hardening Linux security a bit with Apparmor ** "
    sudo mkdir -p /etc/default/grub.d
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT apparmor=1 security=apparmor"'  | sudo tee /etc/default/grub.d/apparmor.cfg
    sudo update-grub
if [[ -z $(which firejail) ]]; then
    sudo aa-enforce firejail-default
fi
}

wireguard_server() {
    wget https://raw.githubusercontent.com/l-n-s/wireguard-install/master/wireguard-install.sh -O wireguard-install.sh
    bash wireguard-install.sh
}

install_openssh() {
    sudo apt-get install openssh-server -y
    sudo ufw enable
    sudo ufw allow OpenSSH
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original
    echo 'PermitRootLogin no 
    PermitEmptyPasswords no' | sudo tee -a /etc/ssh/sshd_config

    sudo bash -c 'cat << EOF > /etc/ssh/sshd_config.suggested
#### Using this file as your sshd_config assumes you have created an
#### sshkey and copied it to your *users* (not roots) $HOME/.ssh/authorized_keys file
#### If you restart the service without doing this, you will be locked out.
#### Before restarting the service, test with: sshd -t
#### Extended test with: sshd -T

## Even if its perfect, you should use this instead, make it a habit:
# sudo kill -SIGHUP $(pgrep -f "sshd -D")

## sshd rereads its configuration file when it receives a hangup 
## signal, SIGHUP, by executing itself with the name and options 
## it was started with, e.g. /usr/sbin/sshd.

## The pgrep -f "sshd -D" part will return only the PID of the 
## sshd daemon process that listens for new connections


Port 2222
PermitRootLogin no
PermitEmptyPasswords no
PasswordAuthentication no
ChallengeResponseAuthentication no

# Set this to yes to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to no.
UsePAM no

AuthenticationMethods publickey
PubkeyAuthentication yes

## Expect .ssh/authorized_keys2 to be disregarded by default in future.
AuthorizedKeysFile	.ssh/authorized_keys .ssh/authorized_keys2

ClientAliveInterval 300
ClientAliveCountMax 2

X11Forwarding no
AllowAgentForwarding no
AllowTcpForwarding no

MaxAuthTries 5
MaxSessions 2
TCPKeepAlive no
Compression no

## Allow client to pass locale environment variables
AcceptEnv LANG LC_*

## override default of no subsystems
Subsystem	sftp	/usr/lib/openssh/sftp-server


## Add your users or groups here
## Ex. 
#AllowUsers john sarah erik
#AllowGroups group1 staff mybackups

#AllowUsers
#AllowGroups

## Logging
#SyslogFacility AUTH
LogLevel VERBOSE



## To receive emails** upon ssh logins getting root access,
## enter the following in /root/.bashrc , replacing 
## ServerName and your@email.com with your own:
## **Must have mailx package installed

# echo "ALERT - Root Shell Access (ServerName) on:" `date` `who` | mail -s "Alert: Root Access from `who | cut -d"(" -f2 | cut -d")" -f1`" your@email.com




#### UNUSED OR DEFAULTS FROM SYSTEM  ###

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

## For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#HostbasedAuthentication no
## Change to yes if you dont trust ~/.ssh/known_hosts for
## HostbasedAuthentication
#IgnoreUserKnownHosts no
## Dont read the users ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

## Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no

## GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no

#GatewayPorts no
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
#PrintMotd no
#PrintLastLog yes

#PermitUserEnvironment no

#ClientAliveInterval 0
#UseDNS no
#PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# Example of overriding settings on a per-user basis
#Match User anoncvs
#	X11Forwarding no
#	AllowTcpForwarding no
#	PermitTTY no
#	ForceCommand cvs server



####   SOURCES:  #####
## https://securitytrails.com/blog/mitigating-ssh-based-attacks-top-15-best-security-practices

## https://askubuntu.com/questions/462968/take-changes-in-file-sshd-config-file-without-server-reboot

## https://stribika.github.io/2015/01/04/secure-secure-shell.html
EOF'

sudo systemctl enable ssh
}

install_fail2ban() {
    sudo apt-get install -y fail2ban
    sudo systemctl start fail2ban
    sudo systemctl enable fail2ban
    sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.original
    echo '[sshd]
    enabled = true
    port = 22
    filter = sshd
    logpath = /var/log/auth.log
    maxretry = 4' | sudo tee -a /etc/fail2ban/jail.local
    echo_warn "DONT FORGET TO ADJUST THIS IF YOU CHANGE THE DEFAULT SSH PORT"
}

install_speedtestcli() {
    sudo apt-get install speedtest-cli -y
}

setup_sftp() {
    echo 'Match group sftp
    ChrootDirectory /home
    X11Forwarding no
    AllowTcpForwarding no
    ForceCommand internal-sftp' | sudo tee -a /etc/ssh/sshd_config
    sudo kill -SIGHUP $(pgrep -f "sshd -D")
}

# Message of the day 
add_daymsg() {
wget https://raw.githubusercontent.com/jwandrews99/Linux-Automation/master/misc/motd.sh
sudo mv motd.sh /etc/update-motd.d/05-info
sudo chmod +x /etc/update-motd.d/05-info
}

unattended_sec() {
# Automatic downloads of security updates
sudo apt-get install -y unattended-upgrades
echo 'Unattended-Upgrade::Allowed-Origins {
   "${distro_id}:${distro_codename}-security";
//  "${distro_id}:${distro_codename}-updates";
//  "${distro_id}:${distro_codename}-proposed";
//  "${distro_id}:${distro_codename}-backports";
}
Unattended-Upgrade::Automatic-Reboot "true"; 
};' | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades
}

add_usersudo() {
    apt install -y sudo useradd
    useradd -m -s /bin/bash -U eljefe
    usermod -aG sudo,adm,systemd-journal,netdev,lp eljefe
    cp -r $HOME/.ssh /home/eljefe/.ssh
    chown -R eljefe:eljefe /home/eljefe/.ssh
}

###### Beginning of script   #####


# Goal: Script which automatically sets up a new Ubuntu Machine after installation
# This is a basic install, easily configurable to your needs

# Test to see if user is running with root privileges.
if [[ "${UID}" -ne 0 ]]
then
 echo 'Must execute with sudo or root' >&2
 exit 1
fi

echo_info '
    ____                __       
   / __ \ ____   _____ / /_      
  / /_/ // __ \ / ___// __/______
 / ____// /_/ /(__  )/ /_ /_____/
/_/     \____//____/ \__/        
                                 '
                                                                                           
echo_info '
    ____              __          __ __           
   /  _/____   _____ / /_ ____ _ / // /___   _____
   / / / __ \ / ___// __// __ `// // // _ \ / ___/
 _/ / / / / /(__  )/ /_ / /_/ // // //  __// /    
/___//_/ /_//____/ \__/ \__,_//_//_/ \___//_/  '

sleep 3

 
echo_prompt "Will you be installing a webserver?[y/n]"
read install_webserver

case $install_webserver in
    Y)
        echo_info "That's whats up. We'll configure that later"
        sleep 2
        echo_info "Installing a few packages first"
        sudo apt-get install --install-recommends tasksel gdebi dialog -y
            ;;
    y)
        echo_info "That's whats up. We'll configure that later"
        sleep 2
        echo_info "Installing a few packages first"
        sudo apt-get install --install-recommends tasksel gdebi dialog -y
            ;;
    N)
        echo_info "Fsho."
        sleep 2
        echo_info "Installing a few packages"
        sudo apt-get install --install-recommends gdebi dialog -y
            ;;
    n)
        echo_info "Fsho."
        sleep 2
        echo_info "Installing a few packages"
        sudo apt-get install --install-recommends gdebi dialog -y
            ;;
    *)
        echo_fail "Bruh."
        sleep 1
        echo_warn "You only had TWO options"
        sleep 1
        echo_info "Terrible. Take a lap"
        sleep 2
        exit 1
            ;;
esac


cmd=(dialog --separate-output --checklist "Software To Install. Default is to Install None. Navigate with Up/Down Arrows. Select/Unselect with Spacebar. Hit Enter key When Finished To Continue. ESC key/Cancel continues without installing any options" 22 126 16)
options=(1 "OpenSSH server. Recommended even if already have ssh server running" on
         2 "Fail2ban" off
         3 "Speedtest-cli" off
         4 "Inxi: System/Hardware Identifier" off
         5 "SFTP Server / FTP server that runs over ssh" off
         6 "Docker: Run Apps in Isolated Containers" off
         7 "Docker-Compose: Simplified Docker Container configuration" off
         8 "Wireguard VPN server" off
         9 "TeamViewer: Remote Desktop Sharing" off
         10 "Tor: Onion Routing for (kind of) Anonymous Secure Browsing" off
         11 "OnionShare: Share Files Securely Over Tor Network && TorBrowser-Launcher (Needs Tor)" off
         12 "Google Cloud Platform SDK CommandLine Tools" off
         13 "NodeJS 12 && NPM package manager" off
         14 "YARN: Additional NodeJS packagemanager" off
         15 "FireJail: Application Sandbox" off
         16 "Your usual Linux packages (User configured)" off
         17 "Harden Linux by loading Apparmor at boot" off
         18 "Add motd message of the day" off
         19 "Create user with sudo privilges" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

echo_note " ********************************************* "
echo -e "                                                 "
echo_info "       Ensuring system is up to date            "
echo -e "                                                 "
echo_note " ********************************************* "

sleep 1
sudo DEBIAN_FRONTEND=noninteractive apt-get update 

# Upgrade the system
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y


for apps in $choices
do
    case $apps in
        1)
            install_openssh
            ;;
        2)
            install_fail2ban
            ;;
        3)
            install_speedtestcli
            ;;
        4)
            install_inxi
            ;;
        5)
            install_sftp
            ;;
        6)
            install_dockerce
            ;;
        7)
            install_dockercompose
            ;;
        8)
            wireguard_server
            ;;
        9)
            install_teamviewer
            ;;
        10)
            install_tor
            ;;
        11)
            install_micahs
            ;;
        12)
            install_googlecloudSDK
            ;;
        13)
            install_node
            ;;
        14)
            install_yarn
            ;;
        15)
            install_firejail
            ;;
        16)
            general_linuxpkgs
            ;;
        17)
            apparmor_grub
            ;;
        18)
            add_daymsg
            ;;
        19)
            add_usersudo
            ;;
        
    esac
done




echo_note " ###################################################################################################### "
echo_info "
                                        A few tid bits

- In order to use SpeedTest - Just use 'speedtest' in the cli

- Reboot your server to fully configure the vpn service

- When using the VPN service on a device simply use the config file in you home directory. 
To create a new config enter  bash wireguard-install.sh in the cli and choose a new name

- If you installed Docker a portainer management image is running on ip:9000 

- Look in /etc/ssh/sshd_config.suggested for a hardened ssh configuration

- The created user with sudo privileges needs a password. Give it a password with the following before blocking root logins: passwd username 

"
echo_note " ###################################################################################################### "

sleep 7

case $install_webserver in
    Y)
        echo_info "Lets install that web server"
        sleep 2
        sudo tasksel
            ;;
    y)
        echo_info "Lets install that web server"
        sleep 2
        sudo tasksel
            ;;
    *)
        echo_note "We're done here"
            ;;
esac

echo_note "Cleaning Up."
sudo apt autoremove
sudo apt autoclean
sudo apt clean 

exit 0
