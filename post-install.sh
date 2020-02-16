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
echo_prompt() { echo -e "${ANSI_YEL}${@}${ANSI_RST}"; }
echo_note()   { echo -e "${ANSI_GRN}${@}${ANSI_RST}"; }
echo_info()   { echo -e "${ANSI_WHT}${@}${ANSI_RST}"; }
echo_warn()   { echo -e "${ANSI_YEL}${@}${ANSI_RST}"; }
echo_debug()  { echo -e "${ANSI_VIO}${@}${ANSI_RST}"; }
echo_fail()   { echo -e "${ANSI_RED}${@}${ANSI_RST}"; }


## Add your favorite/commonly used packages available from the system's package maanger here:
general_linuxpkgs() {
    sudo DEBIAN_FRONTEND=noninteractive apt install htop git apt-transport-https zip unzip netcat nano wdiff -y
}


source ./functions.txt


###### Beginning of script   #####


# Test to see if user is running with root privileges.
if [[ "${UID}" -ne 0 ]]
then
 echo 'Must execute with sudo or root' >&2
 exit 1
fi

echo_note '
    ____                  __       
   / __ \  ___    ____   / /_      
  / /_/ / / __ \ / ___/ / __/ ______
 / ____/ / /_/ /(__   )/ /_  /_____/
/_/      \____/ /____/ \__/        
                                 '
                                                                                           
echo_note '
    ____              __           __ __           
   /  _/____   _____ / /_  ____ _ / // /___   _____
   / / / __ \ / ___// __/ / __ `// // // _ \ / ___/
 _/ / / / / / \__  )/ /_ / /_/ // // //  __// /    
/___//_/ /_/ /____/ \__/ \__,_//_//_/ \___//_/  

'

sleep 2

 
echo_prompt "Will you be installing a webserver?[y/n]"
read install_webserver

case $install_webserver in
    Y)
        echo_note "That's whats up. We'll configure that later"
        sleep 2
        echo_info "Installing a few packages first"
        sleep 2
        sudo apt-get install --install-recommends tasksel gdebi dialog -y
            ;;
    y)
        echo_note "That's whats up. We'll configure that later"
        sleep 2
        echo_info "Installing a few packages first"
        sleep 2
        sudo apt-get install --install-recommends tasksel gdebi dialog -y
            ;;
    N)
        echo_note "Fsho."
        sleep 2
        echo_info "Installing a few packages"
        sleep 2
        sudo apt-get install --install-recommends gdebi dialog -y
            ;;
    n)
        echo_note "Fsho."
        sleep 2
        echo_info "Installing a few packages"
        sleep 2
        sudo apt-get install --install-recommends gdebi dialog -y
            ;;
    *)
        echo_fail "Bruh."
        sleep 1
        echo_warn "You only had TWO options."
        sleep 2
        echo_warn "Terrible. Take a lap."
        sleep 2
        exit 1
            ;;
esac


echo_prompt "Create a regular user with sudo privileges [y/n]"
read create_user
case $create_user in
    Y)
        echo_prompt "Enter username: "
        read new_user
        add_usersudo
        sleep 5
            ;;
    y)
        echo_prompt "Enter username: "
        read new_user
        add_usersudo
        sleep 5
            ;;
    N)
        echo_note "Fsho."
        sleep 2
            ;;
    n)
        echo_note "Fsho."
        sleep 2
            ;;
    *)
        echo_fail "Bruh."
        sleep 1
        echo_warn "You only had TWO options."
        sleep 2
        echo_warn "Terrible. Take a lap."
        sleep 2
        exit 1
            ;;
esac

cmd=(dialog --separate-output --checklist "Default is to Install None. Navigate with Up/Down Arrows. \n 
Select/Unselect with Spacebar. Hit Enter key When Finished To Continue. \n
ESC key/Cancel will continue without installing any options \n
Use Ctrl+c to quit" 22 126 16)
options=(1 "OpenSSH server. Recommended even if already have ssh server running" off
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
         16 "Your usual Linux packages (User configured at top of this script)" off
         17 "Harden Linux by loading Apparmor at boot" off
         18 "Add System Stats message of the day" off
         19 "Set up Unattended Updates (security updates only)" off)
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
            unattended_sec
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

- Dont forget to give $new_user a password for using sudo before disabling root login!

"
echo_note " ###################################################################################################### "

sleep 7

case $install_webserver in
    Y)
        echo_note "Lets install that web server"
        sleep 2
        sudo tasksel
            ;;
    y)
        echo_note "Lets install that web server"
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
