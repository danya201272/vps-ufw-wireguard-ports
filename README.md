# vps-ufw-wireguard-ports
This script create a wireguard vpn connection with local server and vps server. Settings ufw rules and nat and port forwarding on VPS.
# VPS installer
Он помогает сразу открывать на новой машине vps порты для игрового сервера.
Делает vpn туннель wireguard между vps и свойм сервером в локальной сети с ip публичным статическим или через DDNS.
Делает ipv4 и ipv6 NAT,Route и Port Forwading через ufw, и ставит fail2ban для SSH.
А также выключает ICMP пакеты.
Доступ к vps через ssh и wireguard будут иметь только ip указанный вами (ip статический или с ddns).
Wireguard порт указанный при настройке.
Также установлены ufw limit на порты игрового сервера.
Подключение к SSH и Wireguard будет доступно только через IP вашего сервера дома или за туннелем wg0(для других порты, кроме игровых будут закрыты).

IP Игрового Сервера на локальной машине должен ссылаться на Wireguard IP Client(10.66.66.2).
## Requirements
- Ubuntu >= 18.04
## Usage
Для начала работы скрипта нужно прописать команды в консоли ssh на Ubuntu VPS сервере:

```bash
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y && sudo apt-get -y install curl ; sudo curl --insecure -O https://raw.githubusercontent.com/danya201272/vps-ufw-wireguard-ports/main/vps_start.sh ; sudo chmod +x vps_start.sh ; sudo ./vps_start.sh
```

## AntiDdos Rules UFW
```bash
sudo cat /etc/ufw/before.rules
```

```bash
*filter
:ufw-gameudp - [0:0]
:ufw-gametcp - [0:0]
:ufw-gameudp-logdrop - [0:0]
:ufw-gametcp-logdrop - [0:0]
# End required lines
# allow all on loopback
# ANTIDDOS Rules **************
-A ufw-before-input -p tcp -m multiport --dports ${GAME_TCP} -j ufw-gametcp
-A ufw-before-input -p udp -m multiport --dports ${GAME_UDP} -j ufw-gameudp
# Limit connections per Class C
-A ufw-gametcp -p tcp --syn -m connlimit --connlimit-above 100 --connlimit-mask 24 -j ufw-gametcp-logdrop
# Limit connections per IP
-A ufw-gametcp -m state --state NEW -m recent --name conn_per_ip --set
-A ufw-gametcp -m state --state NEW -m recent --name conn_per_ip --update --seconds 1 --hitcount 20 -j ufw-gametcp-logdrop
# Finally accept
-A ufw-gameudp -j ACCEPT
-A ufw-gametcp -j ACCEPT
# Log
-A ufw-gameudp-logdrop -m limit --limit 10/s --limit-burst 50 -j LOG --log-prefix "[UFW GAMEUDP DROP]" # 50 Kbits/s
-A ufw-gametcp-logdrop -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix "[UFW GAMETCP DROP]"
-A ufw-gameudp-logdrop -j DROP
-A ufw-gametcp-logdrop -j DROP
# ANTIDDOS Rules ENDS**********
```
## UPDATE SYSCTL.CONF
```bash
sudo wget -q -c https://raw.githubusercontent.com/danya201272/vps-ufw-wireguard-ports/main/sysctl.conf -O /etc/sysctl.conf
```
```conf
# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0 
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Ignore send redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Block SYN attacks
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_syn_retries = 5

# Log Martians
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Ignore Directed pings
net.ipv4.icmp_echo_ignore_all = 1

# Hide kernel pointers
kernel.kptr_restrict = 2

# Enable panic on OOM
vm.panic_on_oom = 1

# Reboot kernel ten seconds after OOM
kernel.panic = 10

# Tuning
net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_orphan_retries = 0
net.core.netdev_max_backlog = 5000

net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 5
```




