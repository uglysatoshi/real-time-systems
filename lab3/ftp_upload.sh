#!/bin/bash

# === Переменные ===
FTP_SERVER="192.168.0.117"                                      # IP или хост FTP-сервера
FTP_USER="labuser"                                              # Логин
FTP_PASS="7145"                                                 # Пароль
LOCAL_FILE="/home/valery/real-time-systems/lab3/file.txt"       # Файл, который загружаем
REMOTE_DIR="/home/labuser/"                                     # Директория на сервере

# Проверка существования файла
if [[ ! -f "$LOCAL_FILE" ]]; then
    echo "Ошибка: Файл $LOCAL_FILE не найден!"
    exit 1
fi

# Загрузка файла через FTP
echo "Подключаемся к FTP и загружаем $LOCAL_FILE в $REMOTE_DIR..."
ftp -inv $FTP_SERVER <<EOF
user $FTP_USER $FTP_PASS
cd $REMOTE_DIR
put $LOCAL_FILE
bye
EOF

echo "✅ Файл успешно загружен на FTP-сервер!"
