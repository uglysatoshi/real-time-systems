#!/bin/bash

echo "Обновление пакетов..."
sudo apt update && sudo apt upgrade -y

echo "Установка серверных компонентов..."
sudo apt install -y \
    openssh-server \
    postgresql \
    vsftpd \
    openvpn \
    tightvncserver \
    samba \
    telnetd \
    netcat-openbsd

# === НАСТРОЙКА SSH ===
echo "Включение SSH-сервера..."
sudo systemctl enable --now ssh

# === НАСТРОЙКА PostgreSQL ===
echo "Настройка PostgreSQL..."
sudo systemctl enable --now postgresql
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

# === НАСТРОЙКА FTP (vsftpd) ===
echo "Настройка FTP..."
sudo systemctl enable --now vsftpd
sudo sed -i 's/^#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf
echo "allow_writeable_chroot=YES" | sudo tee -a /etc/vsftpd.conf
sudo systemctl restart vsftpd

# === НАСТРОЙКА VNC ===
echo "Настройка VNC..."
sudo -u $(logname) tightvncserver :1

# === НАСТРОЙКА SAMBA ===
echo "Настройка Samba..."
sudo systemctl enable --now smbd
echo -e "[shared]\n   path = /srv/samba/share\n   browseable = yes\n   read only = no\n   guest ok = yes" | sudo tee -a /etc/samba/smb.conf
sudo mkdir -p /srv/samba/share
sudo chmod -R 777 /srv/samba/share
sudo systemctl restart smbd

# === НАСТРОЙКА TELNET ===
echo "Запуск Telnet-сервера..."
sudo systemctl enable --now inetd

# === НАСТРОЙКА NETCAT ===
echo "Запуск Netcat для прослушивания порта 4444..."
sudo nc -lvnp 4444 &

# === СОЗДАНИЕ ТЕСТОВОГО ПОЛЬЗОВАТЕЛЯ ===
TEST_USER="labuser"
TEST_PASS="labpassword"
echo "Создание тестового пользователя $TEST_USER..."
sudo useradd -m -s /bin/bash "$TEST_USER"
echo "$TEST_USER:$TEST_PASS" | sudo chpasswd
echo "$TEST_USER" | sudo tee -a /etc/vsftpd.userlist

# === ВЫВОД ИНФОРМАЦИИ ===
echo "✅ УСТАНОВКА ЗАВЕРШЕНА!"
echo "Тестовый пользователь: $TEST_USER / Пароль: $TEST_PASS"
echo "PostgreSQL: логин postgres / пароль postgres"
echo "FTP, SMB, Telnet, VNC, SCP готовы к тестированию!"
