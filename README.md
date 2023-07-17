# vps-ufw-wireguard-ports
This script create a wireguard vpn connection with local server and vps server. Settings ufw rules and nat and port forwarding on VPS.
# VPS installer
Он помогает сразу открывать на новой машине vps порты для игрового сервера.
Делает vpn туннель wireguard между vps и свойм сервером в локальной сети с ip публичным статическим или через DDNS.
Делает ipv4 и ipv6 NAT,Route и Port Forwading через ufw, и ставит fail2ban для SSH.
А также выключает ICMP пакеты.
Доступ к vps через ssh и wireguard будут иметь только ip указанный вами (ip статический или с ddns).
Wireguard порт указанный при настройке.
Также установлены ufw limit на порт ssh и порты игрового сервера.
Подключение к SSH и Wireguard будет доступно только через IP вашего сервера дома или за туннелем wg0(для других порты, кроме игровых будут закрыты).
## Requirements
- Ubuntu >= 18.04
## Usage
Для начала работы скрипта нужно прописать команды в консоли ssh на Ubuntu VPS сервере:

```bash
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
sudo apt-get -y install curl
sudo apt-get -y install bind9-utils
sudo curl -O https://raw.githubusercontent.com/danya201272/vps-ufw-wireguard-ports/main/vps_start.sh
sudo chmod +x vps_start.sh
sudo ./vps_start.sh
```





