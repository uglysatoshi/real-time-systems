#!/bin/bash

# === Параметры ===
TELNET_HOST="192.168.0.117"   # IP-адрес удаленного хоста
TELNET_PORT="23"              # Порт Telnet, по умолчанию 23
TELNET_USER="labuser"         # Имя пользователя для подключения
TELNET_PASS="7145"            # Пароль пользователя для подключения

# === Проверка прав ===
if [[ $EUID -ne 0 ]]; then
    echo "Этот скрипт нужно запускать с правами sudo!"
    exit 1
fi

# === Подключение через Telnet ===
echo "Подключаемся к $TELNET_HOST:$TELNET_PORT..."
telnet $TELNET_HOST $TELNET_PORT <<EOF
$TELNET_USER
$TELNET_PASS
neofetch
EOF

echo "✅ Подключение через Telnet завершено!"
