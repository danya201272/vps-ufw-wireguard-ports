#!/bin/bash
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get full-upgrade -y
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
sudo apt-get -y install openssh-server
sudo apt-get -y install curl
sudo apt-get -y install bind9-utils
sudo apt-get -y install cron
sudo apt install openssh-server -y
sudo apt install curl -y
sudo apt install bind9-utils -y
sudo apt install cron -y
sudo systemctl enable cron
sudo systemctl enable sshd
sudo systemctl enable ssh


read -rp "Нужно сменить пароль root?(Y/N): " -e -i N ROOTPASSWORDI
if [[ $ROOTPASSWORDI == "y" || $ROOTPASSWORDI == "Y" || $ROOTPASSWORDI == "yes" || $ROOTPASSWORDI == "Yes" || $ROOTPASSWORDI == "Д" || $ROOTPASSWORDI == "Да" || $ROOTPASSWORDI == "д" || $ROOTPASSWORDI == "да" ]]
then
	sudo passwd root
fi
	
read -rp "Введите порт для SSH(22): " -e -i 22 SSH_PORT

ip -br a

SERVER_NICCCCC1="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
	until [[ ${WANPORTIK} =~ ^[a-zA-Z0-9_]+$ ]]; do
		read -rp "Напиши название интерфейса VPS с доступом в интернет(пример eth0,enp24s0): " -e -i "${SERVER_NICCCCC1}" WANPORTIK
	done

SERVER_PUB_IPSS=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | awk '{print $1}' | head -1)
	if [[ -z ${SERVER_PUB_IPSS} ]]; then
		# Detect public IPv6 address
		SERVER_PUB_IPSS=$(ip -6 addr | sed -ne 's|^.* inet6 \([^/]*\)/.* scope global.*$|\1|p' | head -1)
	fi
	read -rp "IPv4 or IPv6 адрес выхода в интернет VPS для SSH remote_ip: " -e -i "${SERVER_PUB_IPSS}" SERVER_PUB_IPSS

read -rp "Нужно ли отключение root для SSH и добавление нового пользователя для SSH(Y/N): " -e -i Y ROOOTS
if [[ $ROOOTS == "y" || $ROOOTS == "Y" || $ROOOTS == "yes" || $ROOOTS == "Yes" || $ROOOTS == "Д" || $ROOOTS == "Да" || $ROOOTS == "д" || $ROOOTS == "да" ]]
then
	read -p "Введите имя нового пользователя(bino):" snames
	read -s -p "Введите пароль для нового пользователя:" sspassword
	EncryptedPasswordHeres=$(perl -e 'print crypt($ARGV[0], "sspassword")' $sspassword)
	sudo useradd -s /bin/bash -m -p "$EncryptedPasswordHeres" "$snames"
	sudo sed -i "/Port /c Port ${SSH_PORT}" /etc/ssh/sshd_config
	sudo sed -i "/PermitRootLogin /c PermitRootLogin no" /etc/ssh/sshd_config
	sudo usermod -aG sudo $snames
	echo ""
	echo "Ваш новый логин SSH: $snames и порт SSH ${SSH_PORT}, пароль: ${sspassword}"
	read -rp "Нужен вход по SSH RSA ключам для пользователя ${snames}?(Y/N): " -e -i Y SSHRSAA
	if [[ $SSHRSAA == "y" || $SSHRSAA == "Y" || $SSHRSAA == "yes" || $SSHRSAA == "Yes" || $SSHRSAA == "Д" || $SSHRSAA == "Да" || $SSHRSAA == "д" || $SSHRSAA == "да" ]]
	then
		sudo -u $snames ssh-keygen -t rsa -b 3072
		sudo -u $snames ssh-copy-id ${snames}@${SERVER_PUB_IPSS}
		echo "Private KEY SSH RSA copy in id_rsa"
		sudo cat "/home/${snames}/.ssh/id_rsa"
		read -rp "Убрать вход по паролю SSH?(Y/N): " -e -i Y SSHRSAAPASS
		if [[ $SSHRSAAPASS == "y" || $SSHRSAAPASS == "Y" || $SSHRSAAPASS == "yes" || $SSHRSAAPASS == "Yes" || $SSHRSAAPASS == "Д" || $SSHRSAAPASS == "Да" || $SSHRSAAPASS == "д" || $SSHRSAAPASS == "да" ]]
		then
			sudo sed -i "/PasswordAuthentication /c PasswordAuthentication no" /etc/ssh/sshd_config
		fi
	fi
else
	sudo sed -i "/Port /c Port ${SSH_PORT}" /etc/ssh/sshd_config
fi

read -p "Порт Игры с локалки по TCP Можно писать так (12,22) или (1501:2000) или (1000,1001,1501:2000):" GAME_TCP

read -p "Порт Игры с локалки по UDP Можно писать так (12,22) или (1501:2000) или (1000,1001,1501:2000):" GAME_UDP


sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -F INPUT
sudo iptables -F OUTPUT
sudo iptables -F FORWARD
sudo iptables -F

sudo curl --insecure -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
sudo chmod +x wireguard-install.sh
sudo ./wireguard-install.sh

read -rp "Выше в консоли ищите Client WireGuard IPv4:(пример 10.66.66.2): " -e -i 10.66.66.2 ip_vpn_client

read -p "Выше в консоли ищите Server WireGuard port [1-65535]:(пример 50821):" WIREGUARD_PORT

read -rp "Выше в консоли ищите WireGuard interface name:(пример wg0): " -e -i wg0 VPNSS

sudo apt-get install ufw -y
sudo apt install ufw -y
sudo ufw reset
sudo ufw disable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw logging on
sudo ufw logging low


read -rp "У вас серый ip с DDNS в локалке за туннелем(Y/N): " -e -i Y SERYI
if [[ $SERYI == "y" || $SERYI == "Y" || $SERYI == "yes" || $SERYI == "Yes" || $SERYI == "Д" || $SERYI == "Да" || $SERYI == "д" || $SERYI == "да" ]]
then
	sudo ufw allow 53/tcp comment "DDNS script"
	sudo ufw allow 53/udp comment "DDNS script"
	read -p "DDNS адрес пишите с NO-IP(пример hostesd.no-ip.com):" DDNSIPSSS
	HOSTNAMESSSS=$(host $DDNSIPSSS | head -n1 | cut -f4 -d ' ')
	echo "Создаю скрипт обновления DDNS: ddns_update.sh"
	sudo crontab -l | sudo grep -v '/usr/local/bin/ddns_update.sh'  | sudo crontab -
	sudo rm -f /usr/local/bin/ddns_update.sh
	sudo curl --insecure -O https://raw.githubusercontent.com/danya201272/vps-ufw-wireguard-ports/main/ddns_update.sh
	sudo chmod +x ddns_update.sh
	sudo sed -i "2c HOSTNAMESSSS=${DDNSIPSSS} # С NO-IP ip локального сервера" ddns_update.sh
	sudo sed -i "3c WIREGUARD_PORT=${WIREGUARD_PORT} # WIREGUARD Порт" ddns_update.sh
	sudo sed -i "4c SSH_PORT=${SSH_PORT} #  SSH Port" ddns_update.sh
	sudo sed -i "5c FIRST_IP=${HOSTNAMESSSS} # Первое серое IP c DDNS адреса" ddns_update.sh
	sudo sed -i "6c WANPUB=${WANPORTIK} # Интерфейс VPS с выходом в интернет" ddns_update.sh
	sudo mv -f ddns_update.sh /usr/local/bin
	(sudo crontab -l 2>/dev/null; echo "*/2 * * * * /usr/local/bin/ddns_update.sh > /dev/null 2>&1") | sudo crontab -
	echo "Скрипт ddns_update.sh в /usr/local/bin/ddns_update.sh"
	echo "Скрипт ddns_update.sh добавлен в sudo crontab -l каждые 2 минуты"
	sudo ufw delete allow 53/tcp
	sudo ufw delete allow 53/udp
else
    read -p "Пишите IP Статику от провайдера от локального сервера дома(пример 176.213.115.169):" HOSTNAMESSSS
fi


read -rp "Нужен ли IPV6 на NAT и UFW?(Y/N): " -e -i N IPV6666
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
	sudo sed -i 's|net/ipv6/conf/all/forwarding=1|net/ipv6/conf/all/forwarding=0|g' /etc/ufw/sysctl.conf # IPV6
	sudo sed -i 's|#net/ipv6/conf/all/forwarding=1|net/ipv6/conf/all/forwarding=0|g' /etc/ufw/sysctl.conf  # IPV6
	sudo sed -i 's|net/ipv6/conf/default/forwarding=1|net/ipv6/conf/default/forwarding=0|g' /etc/ufw/sysctl.conf # IPV6
	sudo sed -i 's|#net/ipv6/conf/default/forwarding=1|net/ipv6/conf/default/forwarding=0|g' /etc/ufw/sysctl.conf  # IPV6
	sudo sed -i 's|IPV6=yes|IPV6=no|g' /etc/default/ufw # IPV6
	sudo sed -i 's|#IPV6=yes|IPV6=no|g' /etc/default/ufw  # IPV6
	sudo sysctl -p
fi

sudo ufw allow from $HOSTNAMESSSS to any port $SSH_PORT proto tcp comment "$DDNSIPSSS SSH"
sudo ufw allow from $HOSTNAMESSSS to any port $WIREGUARD_PORT proto udp comment "$DDNSIPSSS WIREGUARD"
sudo ufw allow ${GAME_TCP}/tcp comment "Public ip open to GAME_TCP_Port"
sudo ufw allow ${GAME_UDP}/udp comment "Public ip open to GAME_UDP_Port"
sudo ufw limit ${GAME_TCP}/tcp comment "OPEN PORT GAME TCP Limit"
sudo ufw limit ${GAME_UDP}/udp comment "OPEN PORT GAME UDP Limit"
sudo ufw allow in on $VPNSS from $ip_vpn_client to any port $SSH_PORT proto tcp comment "Access VPN client to SSH"

read -rp "Нужна ли Блокировка ICMP (лучше включить блокировку)(Y/N): " -e -i Y ICMPSSSS
if [[ $ICMPSSSS == "y" || $ICMPSSSS == "Y" || $ICMPSSSS == "yes" || $ICMPSSSS == "Yes" || $ICMPSSSS == "Д" || $ICMPSSSS == "Да" || $ICMPSSSS == "д" || $ICMPSSSS == "да" ]]
then
	sudo sysctl -w net.ipv4.icmp_echo_ignore_all=1 # Блокировка ICMP
	sudo sed -i '/ufw-before-input.*icmp/s/ACCEPT/DROP/g' /etc/ufw/before.rules
	sudo sysctl -p
else
	sudo sysctl -w net.ipv4.icmp_echo_ignore_all=0 # Разблокировка ICMP
	sudo sed -i '/ufw-before-input.*icmp/s/DROP/ACCEPT/g' /etc/ufw/before.rules
fi


read -rp "Нужен ли fail2ban на SSH?(Y/N): " -e -i Y FAIL2TOBANSSS
if [[ $FAIL2TOBANSSS == "y" || $FAIL2TOBANSSS == "Y" || $FAIL2TOBANSSS == "yes" || $FAIL2TOBANSSS == "Yes" || $FAIL2TOBANSSS == "Д" || $FAIL2TOBANSSS == "Да" || $FAIL2TOBANSSS == "д" || $FAIL2TOBANSSS == "да" ]]
then
	sudo apt-get install fail2ban -y
	sudo apt install fail2ban -y
	systemctl start fail2ban
	systemctl enable fail2ban
	sudo cp /etc/fail2ban/jail.{conf,local}
	sudo sed -i "/ignoreip =/c ignoreip = 127.0.0.1/8 ::1 ${ip_vpn_client}" /etc/fail2ban/jail.local
	sudo sed -i "/banaction =/c banaction = ufw" /etc/fail2ban/jail.local
	sudo sed -i "/banaction_allports =/c banaction_allports = ufw" /etc/fail2ban/jail.local
	sudo sed -i "s|port = ssh|port = ssh,sshd,${SSH_PORT}|g" /etc/fail2ban/jail.local
	sudo sed -i "s|port    = ssh|port    = ssh,sshd,${SSH_PORT}|g" /etc/fail2ban/jail.local
	sudo sed -i "s|port     = ssh|port     = ssh,sshd,${SSH_PORT}|g" /etc/fail2ban/jail.local
	sudo systemctl restart fail2ban
fi



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
sudo sed -i "6i -A PREROUTING -i ${WANPORTIK} -p tcp -m multiport --dports ${GAME_TCP} -j DNAT --to-destination ${ip_vpn_client}" /etc/ufw/before.rules
sudo sed -i "7i -A PREROUTING -i ${WANPORTIK} -p udp -m multiport --dports ${GAME_UDP} -j DNAT --to-destination ${ip_vpn_client}" /etc/ufw/before.rules
sudo sed -i "8i # Forward traffic through ${WANPORTIK} - Change to match you out-interface" /etc/ufw/before.rules
sudo sed -i "9i -A POSTROUTING -o ${WANPORTIK} -j SNAT --to-source ${SERVER_PUB_IPSS}" /etc/ufw/before.rules # -j MASQUERADE  при динамическом ip от провайдера VPS
sudo sed -i '10i # dont delete the COMMIT line or these nat table rules wont' /etc/ufw/before.rules
sudo sed -i '11i COMMIT' /etc/ufw/before.rules
sudo sysctl -p
sudo service cron reload


read -rp "Нужен ли AntiDDOS на TCP/UDP?(Y/N): " -e -i Y ANTIDDOSSSS
if [[ $ANTIDDOSSSS == "y" || $ANTIDDOSSSS == "Y" || $ANTIDDOSSSS == "yes" || $ANTIDDOSSSS == "Yes" || $ANTIDDOSSSS == "Д" || $ANTIDDOSSSS == "Да" || $ANTIDDOSSSS == "д" || $ANTIDDOSSSS == "да" ]]
then
sudo sed -i '/*filter/ a \
# **********************DDOS\
:ufw-gameudp - [0:0]\
:ufw-gametcp - [0:0]\
:ufw-gameudp-logdrop - [0:0]\
:ufw-gametcp-logdrop - [0:0]\
# **********************DDOS\\
' /etc/ufw/before.rules
texts1="\"[UFW GAMEUDP DROP]"\"  
texts2="\"[UFW GAMETCP DROP]"\"
sudo sed -i "/# allow all on loopback/ a \
# ANTIDDOS Rules **************\n\
-A ufw-before-input -p tcp -m multiport --dports ${GAME_TCP} -j ufw-gametcp\n\
-A ufw-before-input -p udp -m multiport --dports ${GAME_UDP} -j ufw-gameudp\n\
# Limit connections per Class C\n\
-A ufw-gametcp -p tcp --syn -m connlimit --connlimit-above 100 --connlimit-mask 24 -j ufw-gametcp-logdrop\n\
# Limit connections per IP\n\
-A ufw-gametcp -m state --state NEW -m recent --name conn_per_ip --set\n\
-A ufw-gametcp -m state --state NEW -m recent --name conn_per_ip --update --seconds 1 --hitcount 20 -j ufw-gametcp-logdrop\n\
# Finally accept\n\
-A ufw-gameudp -j ACCEPT\n\
-A ufw-gametcp -j ACCEPT\n\
# Log\n\
-A ufw-gameudp-logdrop -m limit --limit 10/s --limit-burst 50 -j LOG --log-prefix ${texts1}\n\
-A ufw-gametcp-logdrop -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix ${texts2}\n\
-A ufw-gameudp-logdrop -j DROP\n\
-A ufw-gametcp-logdrop -j DROP\n\
# ANTIDDOS Rules ENDS**********\
" /etc/ufw/before.rules
sudo sysctl -p
fi

sudo ufw reload
sudo ufw disable && sudo ufw enable

read -rp "Обновить sysctl.conf для более эффективной работы ядра(на свой страх и риск)?(Y/N): " -e -i N SYSCTLS
if [[ $SYSCTLS == "y" || $SYSCTLS == "Y" || $SYSCTLS == "yes" || $SYSCTLS == "Yes" || $SYSCTLS == "Д" || $SYSCTLS == "Да" || $SYSCTLS == "д" || $SYSCTLS == "да" ]]
then
sudo wget -q -c https://raw.githubusercontent.com/danya201272/vps-ufw-wireguard-ports/main/sysctl.conf -O /etc/sysctl.conf
fi

echo "Порт SSH:${SSH_PORT}"
echo "Порт Wireguard:${WIREGUARD_PORT}"
echo "Порт Игровой TCP:${GAME_TCP}"
echo "Порт Игровой UDP:${GAME_UDP}"
echo "IP адрес клиента Wireguard:${ip_vpn_client}"
echo "Ваш IP публичный адрес DDNS NO-IP(сервера дома):${DDNSIPSSS}"
echo "Ваш IP публичный адрес (сервера дома):${HOSTNAMESSSS}"
echo "Имя нового пользователя SSH:${snames}"
echo "Пароль нового пользователя SSH:${sspassword}"
echo ""
echo ""
echo "Файл конфигурациий для клиента Wireguard сохранять в .conf"
sudo cat `sudo find /root/ -type f -name "*.conf"`

read -rp "Перезагрузить VPS?(Y/N): " -e -i Y VPSRESTARTSSS
if [[ $VPSRESTARTSSS == "y" || $VPSRESTARTSSS == "Y" || $VPSRESTARTSSS == "yes" || $VPSRESTARTSSS == "Yes" || $VPSRESTARTSSS == "Д" || $VPSRESTARTSSS == "Да" || $VPSRESTARTSSS == "д" || $VPSRESTARTSSS == "да" ]]
then
	sudo reboot now
	sudo reboot -f
	sudo shutdown -r now
	sudo systemctl reboot
else
	exit 0
fi