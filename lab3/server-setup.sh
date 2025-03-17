#!/bin/bash

# Проверка прав
if [[ $EUID -ne 0 ]]; then
    echo "Этот скрипт нужно запускать с sudo!"
    exit 1
fi

# === Переменные ===
PG_HBA="/etc/postgresql/*/main/pg_hba.conf"
PG_CONF="/etc/postgresql/*/main/postgresql.conf"
SUBNET="192.168.0.0/24" # Разрешённая подсеть
TEST_USER="labuser"
TEST_PASS="7145"

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
    xinetd \
    telnetd \
    netcat-openbsd \
    neofetch \
    ufw

# === НАСТРОЙКА SSH ===
echo "Включение SSH-сервера..."
sudo systemctl enable --now ssh

# === НАСТРОЙКА PostgreSQL ===
echo "Настройка PostgreSQL..."
sudo systemctl enable --now postgresql
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
sudo -u postgres psql -c "CREATE DATABASE testdb;" 2>/dev/null

# === Разрешаем удалённые подключения в pg_hba.conf ===
echo "Настраиваем pg_hba.conf..."
if ! grep -q "$SUBNET" $PG_HBA; then
    echo "host    all    all    $SUBNET    md5" | sudo tee -a $PG_HBA
else
    echo "Подсеть $SUBNET уже разрешена в pg_hba.conf."
fi

# === Разрешаем прослушивание всех IP в postgresql.conf ===
echo "Настраиваем postgresql.conf..."
sudo sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" $PG_CONF
sudo sed -i "s/^listen_addresses = 'localhost'/listen_addresses = '*'/" $PG_CONF

# === Перезапускаем PostgreSQL ===
echo "Перезапуск PostgreSQL..."
sudo systemctl restart postgresql

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
echo "Конфигурация Telnet-сервера..."

# Создадим конфигурацию для Telnet в xinetd
echo 'service telnet
{
    disable = no
    socket_type = stream
    wait = no
    user = root
    server = /usr/sbin/in.telnetd
    log_on_failure += USERID
}' | sudo tee /etc/xinetd.d/telnet

# Перезапустим сервис xinetd
sudo systemctl enable --now xinetd
sudo systemctl restart xinetd

# Проверяем, что служба работает
if systemctl is-active --quiet inetd; then
    echo "✅ Telnet-сервер успешно запущен и работает!"
else
    echo "❌ Ошибка при запуске Telnet-сервера."
fi

# === Открытие порта в брандмауэре (если используется UFW) ===
echo "Проверим настройки брандмауэра..."
if sudo ufw status | grep -q "active"; then
    echo "Открываем порт 23 (Telnet) в брандмауэре..."
    sudo ufw allow 23/tcp
    sudo ufw reload
    echo "✅ Порт 23 открыт в брандмауэре."
else
    echo "Брандмауфер UFW не активен, пропускаем настройку."
fi

echo "telnet  stream  tcp  nowait  root  /usr/sbin/telnetd  telnetd" | sudo tee -a /etc/inetd.conf
echo "Перезапускаем службу Telnet..."
systemctl restart inetd

# === НАСТРОЙКА NETCAT ===
echo "Запуск Netcat для прослушивания порта 4444..."
sudo nc -lvnp 4444 &

# === СОЗДАНИЕ ТЕСТОВОГО ПОЛЬЗОВАТЕЛЯ ===

echo "Создание тестового пользователя $TEST_USER..."
sudo useradd -m -s /bin/bash "$TEST_USER"
echo "$TEST_USER:$TEST_PASS" | sudo chpasswd
echo "$TEST_USER" | sudo tee -a /etc/vsftpd.userlist

# === ВЫВОД ИНФОРМАЦИИ ===
echo "✅ УСТАНОВКА ЗАВЕРШЕНА!"
echo "Тестовый пользователь: $TEST_USER / Пароль: $TEST_PASS"
echo "PostgreSQL: логин postgres / пароль postgres"
echo "FTP, SMB, Telnet, VNC, SCP готовы к тестированию!"
