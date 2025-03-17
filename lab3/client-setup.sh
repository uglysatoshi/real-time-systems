#!/bin/bash

SERVER_IP=192.168.0.117

# Обновление системы
echo "Обновление списка пакетов..."
sudo apt update && sudo apt upgrade -y

# Установка необходимых пакетов
echo "Установка пакетов..."
sudo apt install -y \
    openssh-client \
    postgresql-client \
    ftp \
    openvpn \
    tigervnc-viewer \
    smbclient \
    telnet \
    netcat-openbsd \
    openssh-sftp-server \
    sshpass \
    expect

# Добавление тестового пользователя
TEST_USER="labuser"
TEST_PASS="labpassword"

echo "Создание пользователя $TEST_USER..."
sudo useradd -m -s /bin/bash "$TEST_USER"
echo "$TEST_USER:$TEST_PASS" | sudo chpasswd

# Создание тестовой SSH-пары
echo "Создание SSH-ключей..."
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
ssh-copy-id -i ~/.ssh/id_rsa labuser@$SERVER_IP

# Вывод информации о системе
echo "Подготовка завершена!"
echo "Тестовый пользователь: $TEST_USER"
echo "Пароль: $TEST_PASS"
echo "Готово к выполнению лабораторных скриптов!"
