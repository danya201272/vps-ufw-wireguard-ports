#!/bin/bash
VPNS=wg0 # Название интерфейса Wireguard
SSH_PORT=22 # Порт SSH Изменять нельзя
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get -y install curl
sudo apt-get -y install bind9-utils

echo "Порт для SSH: ${SSH_PORT}" 

sudo ip -br a
read -p "Напиши название интерфейса VPS с доступом в интернет (пример eth0,enp24s0):" WAN

read -p "Порт Игры с локалки по TCP Можно писать так (8080:8090) или только так (80):" GAME_TCP

read -p "Порт Игры с локалки по UDP Можно писать так (8080:8090) или только так (443):" GAME_UDP


sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -F INPUT
sudo iptables -F OUTPUT
sudo iptables -F FORWARD
sudo iptables -F

sudo curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
sudo chmod +x wireguard-install.sh
sudo ./wireguard-install.sh

read -p "Выше в консоли ищите Client WireGuard IPv4:(пример 10.66.66.2):" ip_vpn_client

read -p "Выше в консоли ищите Server WireGuard port [1-65535]:(пример 60951):" WIREGUARD_PORT

read -p "У вас серый ip с DDNS в локалке за туннелем(Y/N):" SERYI
if [[ $SERYI == "y" || $SERYI == "Y" || $SERYI == "yes" || $SERYI == "Yes" || $SERYI == "Д" || $SERYI == "Да" || $SERYI == "д" || $SERYI == "да" ]]
then
	read -p "DDNS адрес пишите с NO-IP(пример hostesd.no-ip.com):" HOSTNAME
	echo "Создаю скрипт обновления DDNS: ddns_update.sh"
	sudo rm -f ddns_update.sh
	sudo curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
	sudo chmod +x ddns_update.sh
	sudo sed -i "2c HOSTNAME=${HOSTNAME} # С NO-IP или KeenDNS ip локального пк" ddns_update.sh
	sudo sed -i "3c WIREGUARD_PORT=${WIREGUARD_PORT} # WIREGUARD Порт" ddns_update.sh
else
    read -p "Пишите IP Статику(пример 176.213.115.169):" HOSTNAME
	:
fi

sudo apt-get install ufw -y
sudo ufw reset
sudo ufw disable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw logging on
sudo ufw logging low

read -p "Нужен ли IPV6 на NAT и UFW?(Y/N):" IPV6666
if [[ $IPV6666 == "y" || $IPV6666 == "Y" || $IPV6666 == "yes" || $IPV6666 == "Yes" || $IPV6666 == "Д" || $IPV6666 == "Да" || $IPV6666 == "д" || $IPV6666 == "да" ]]
then
	sudo sed -i 's|net/ipv6/conf/all/forwarding=0|net/ipv6/conf/all/forwarding=1|g' /etc/ufw/sysctl.conf # IPV6
	sudo sed -i 's|#net/ipv6/conf/all/forwarding=1|net/ipv6/conf/all/forwarding=1|g' /etc/ufw/sysctl.conf  # IPV6
	sudo sed -i 's|net/ipv6/conf/default/forwarding=0|net/ipv6/conf/default/forwarding=1|g' /etc/ufw/sysctl.conf # IPV6
	sudo sed -i 's|#net/ipv6/conf/default/forwarding=1|net/ipv6/conf/default/forwarding=1|g' /etc/ufw/sysctl.conf  # IPV6
	sudo sed -i 's|IPV6=no|IPV6=yes|g' /etc/default/ufw # IPV6
	sudo sed -i 's|#IPV6=no|IPV6=yes|g' /etc/default/ufw  # IPV6
	sudo sysctl -p
else
	:
fi

sudo ufw allow from $HOSTNAME to any port $SSH_PORT proto tcp
sudo ufw limit $SSH_PORT/tcp comment "SSH limit"
sudo ufw allow from $HOSTNAME to any port $WIREGUARD_PORT proto udp
sudo ufw allow in on $WAN to any port $GAME_TCP proto tcp comment "Public ip open to GAME_TCP_Port"
sudo ufw allow in on $WAN to any port $GAME_UDP proto udp comment "Public ip open to GAME_UDP_Port"
sudo ufw limit $GAME_TCP/tcp comment "GAME TCP Limit"
sudo ufw limit $GAME_UDP/udp comment "GAME UDP Limit"

#sudo ufw route allow in on $WAN out on $VPNS to $ip_vpn_client port $GAME_TCP proto tcp  | /etc/ufw/before.rules -A PREROUTING -i $WAN -p tcp --dport $GAME_TCP -j DNAT --to-destination $ip_vpn_client 

read -p "Нужна ли Блокировка ICMP(Y/N):" ICMPSSSS
if [[ $ICMPSSSS == "y" || $ICMPSSSS == "Y" || $ICMPSSSS == "yes" || $ICMPSSSS == "Yes" || $ICMPSSSS == "Д" || $ICMPSSSS == "Да" || $ICMPSSSS == "д" || $ICMPSSSS == "да" ]]
then
	sudo sysctl -w net.ipv4.icmp_echo_ignore_all=1 # Блокировка ICMP
	sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type destination-unreachable -j ACCEPT/-A ufw-before-input -p icmp --icmp-type destination-unreachable -j DROP/g' /etc/ufw/before.rules # ICMP DROP
	sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type time-exceeded -j ACCEPT/-A ufw-before-input -p icmp --icmp-type time-exceeded -j DROP/g' /etc/ufw/before.rules # ICMP DROP
	sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type parameter-problem -j ACCEPT/-A ufw-before-input -p icmp --icmp-type parameter-problem -j DROP/g' /etc/ufw/before.rules # ICMP DROP
	sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/g' /etc/ufw/before.rules # ICMP DROP
	sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type source-quench -j ACCEPT/-A ufw-before-input -p icmp --icmp-type source-quench -j DROP/g' /etc/ufw/before.rules # ICMP DROP
	sudo sysctl -p
else
	sudo sysctl -w net.ipv4.icmp_echo_ignore_all=0 # Разблокировка ICMP
	:
fi

sudo apt-get install fail2ban -y
systemctl start fail2ban
systemctl enable fail2ban


sudo sed -i 's|net/ipv4/ip_forward=0|net/ipv4/ip_forward=1|g' /etc/ufw/sysctl.conf # IPV4
sudo sed -i 's|#net/ipv4/ip_forward=1|net/ipv4/ip_forward=1|g' /etc/ufw/sysctl.conf # IPV4
sudo sysctl -p

sudo ufw default allow routed # DEFAULT_FORWARD_POLICY="ACCEPT"  /etc/default/ufw 
sudo sysctl -p


sudo sed -i '1i # NAT table rules' /etc/ufw/before.rules
sudo sed -i '2i *nat' /etc/ufw/before.rules
sudo sed -i '3i :PREROUTING ACCEPT [0:0]' /etc/ufw/before.rules
sudo sed -i '4i :POSTROUTING ACCEPT [0:0]' /etc/ufw/before.rules
sudo sed -i '5i # Port Forwardings' /etc/ufw/before.rules
sudo sed -i "6i -A PREROUTING -i ${WAN} -p tcp --dport ${GAME_TCP} -j DNAT --to-destination ${ip_vpn_client}" /etc/ufw/before.rules # "" для работы подстановки переменных 
sudo sed -i "7i -A PREROUTING -i ${WAN} -p udp --dport ${GAME_UDP} -j DNAT --to-destination ${ip_vpn_client}" /etc/ufw/before.rules
sudo sed -i "8i # Forward traffic through ${WAN} - Change to match you out-interface" /etc/ufw/before.rules
sudo sed -i "9i -A POSTROUTING -o ${WAN} -j MASQUERADE" /etc/ufw/before.rules
sudo sed -i '10i # dont delete the COMMIT line or these nat table rules wont' /etc/ufw/before.rules
sudo sed -i '11i COMMIT' /etc/ufw/before.rules
sudo sysctl -p


sudo ufw disable && sudo ufw enable