#!/bin/bash
HOSTNAMESSSS=disabralo.ddns.net # С NO-IP или KeenDNS ip локального пк
WIREGUARD_PORT=50820 # WIREGUARD Порт
SSH_PORT=22 #  SSH Port
FIRST_IP=176.213.113.109 # Первое серое IP c DDNS адреса
WANPUB=ens3 # Интерфейс VPS с выходом в интернет

sudo ufw allow 53/tcp comment "DDNS script"
sudo ufw allow 53/udp comment "DDNS script"
#IF IT DOES NOT WORK, AT LEAST ON UBUNTU INSTALL, bind-utils to get the host command
#sudo crontab -e
#Create a cron */2 * * * * /usr/local/bin/ddns_update.sh > /dev/null 2>&1

#IN bash scrypt echo (sudo crontab -l 2>/dev/null; echo "*/2 * * * * /usr/local/bin/ddns_update.sh > /dev/null 2>&1") | sudo crontab -
pubsss=$(ip --brief address show $WANPUB | awk '{print $3}' | cut -d'/' -f1)
ipss=$(host $HOSTNAMESSSS | head -n1 | cut -f4 -d ' ')
if [ "$ipss" = "$pubsss" ] ; then
sudo ufw delete allow 53/tcp
sudo ufw delete allow 53/udp
exit 0
fi

new_ip=$(host $HOSTNAMESSSS | head -n1 | cut -f4 -d ' ') #new_ip=$(getent hosts $HOSTNAMESSSS | awk '{ print $1 }')
old_ip=$(sudo ufw status | grep $HOSTNAMESSSS | head -n1 | tr -s ' ' | cut -f3 -d ' ')
if [ "$new_ip" = "$old_ip" ] ; then
    echo IP address has not changed
	sudo ufw delete allow 53/tcp
	sudo ufw delete allow 53/udp
else
    if [ -n "$old_ip" ] ; then
        sudo ufw delete allow from $old_ip to any port $SSH_PORT proto tcp
        sudo ufw delete allow from $old_ip to any port $WIREGUARD_PORT proto udp
        sudo ufw delete allow from $FIRST_IP to any port $SSH_PORT proto tcp
        sudo ufw delete allow from $FIRST_IP to any port $WIREGUARD_PORT proto udp
    fi
    sudo ufw allow from $new_ip to any port $SSH_PORT proto tcp comment "$HOSTNAMESSSS  SSH"
    sudo ufw allow from $new_ip to any port $WIREGUARD_PORT proto udp comment "$HOSTNAMESSSS WIREGUARD"
	sudo ufw delete allow 53/tcp
	sudo ufw delete allow 53/udp
    echo UFW have been updated
fi