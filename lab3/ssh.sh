#!/bin/bash

# === НАСТРОЙКИ ===
USER="labuser"         # Имя пользователя на сервере
SERVER="192.168.0.117" # IP или хост сервера
KEY_PATH="$HOME/.ssh/id_rsa" # Путь до приватного ключа

# Проверяем, существует ли ключ
if [[ ! -f "$KEY_PATH" ]]; then
    echo "Ошибка: SSH-ключ не найден ($KEY_PATH). Проверьте путь!"
    exit 1
fi

# Подключение к серверу через SSH
echo "Подключение к $SERVER..."
ssh -i "$KEY_PATH" "$USER@$SERVER"
