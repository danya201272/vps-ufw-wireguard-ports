#!/bin/bash
HOSTNAMESSSS=vvvs.keenetick.pro # С NO-IP или KeenDNS ip локального пк
WIREGUARD_PORT=50820 # WIREGUARD Порт
SSH_PORT=22 #  SSH Port

sudo ufw allow 53/tcp comment "DDNS script"
sudo ufw allow 53/udp comment "DDNS script"
#IF IT DOES NOT WORK, AT LEAST ON UBUNTU INSTALL, bind-utils to get the host command
#sudo crontab -e
#Create a cron */15 * * * * root /usr/local/bin/ddns_update.sh > /dev/null

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
new_ip=$(host $HOSTNAMESSSS | head -n1 | cut -f4 -d ' ') #HOSTNAMESSSS=$(getent hosts $HOSTNAMESSSS | awk '{ print $1 }') host disabralo.ddns.net | head -n1 | cut -f4 -d ' '
old_ip=$(sudo ufw status | grep $HOSTNAMESSSS | head -n1 | tr -s ' ' | cut -f3 -d ' ')
if [ "$new_ip" = "$old_ip" ] ; then
    echo IP address has not changed
	sudo ufw delete allow 53/tcp
	sudo ufw delete allow 53/udp
else
    if [ -n "$old_ip" ] ; then
        sudo ufw delete allow from $old_ip to any port $SSH_PORT proto tcp
        sudo ufw delete allow from $old_ip to any port $WIREGUARD_PORT proto udp
    fi
    sudo ufw allow from $new_ip to any port $SSH_PORT proto tcp comment $HOSTNAMESSSS
    sudo ufw allow from $new_ip to any port $WIREGUARD_PORT proto udp comment $HOSTNAMESSSS
	sudo ufw limit $SSH_PORT/tcp
	sudo ufw delete allow 53/tcp
	sudo ufw delete allow 53/udp
    echo UFW have been updated
fi