#!/bin/bash
HOSTNAME=$HOSTNAME # С NO-IP или KeenDNS ip локального пк
WIREGUARD_PORT=1 # WIREGUARD Порт
SSH_PORT=22 #  SSH Port


#IF IT DOES NOT WORK, AT LEAST ON UBUNTU INSTALL, bind-utils to get the host command

#Create a cron */15 * * * * root bash /path/to/ufw_ddns_update.sh

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
new_ip=$(getent hosts $HOSTNAME | awk '{ print $1 }') # if dont work paste this new_ip=$(host $HOSTNAME | head -n1 | cut -f4 -d ' ') and install sudo apt-get update && sudo apt-get -y install bind9-utils
old_ip=$(/usr/sbin/ufw status | grep $HOSTNAME | head -n1 | tr -s ' ' | cut -f3 -d ' ')
if [ "$new_ip" = "$old_ip" ] ; then
    echo IP address has not changed
else
    if [ -n "$old_ip" ] ; then
        /usr/sbin/ufw delete allow from $old_ip to any port $SSH_PORT proto tcp
        /user/sbin/ufw delete allow from $old_ip to any port $WIREGUARD_PORT proto udp
    fi
    /usr/sbin/ufw allow from $new_ip to any port $SSH_PORT proto tcp comment $HOSTNAME
    /usr/sbin/ufw allow from $new_ip to any port $WIREGUARD_PORT proto udp comment $HOSTNAME
	/usr/sbin/ufw limit $SSH_PORT/tcp
    echo UFW have been updated
fi