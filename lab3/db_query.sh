#!/bin/bash

# === НАСТРОЙКИ ===
DB_USER="postgres"        # Логин БД
DB_PASS="postgres"        # Пароль БД
DB_NAME="testdb"          # Название базы данных
DB_HOST="192.168.0.117"   # IP сервера
QUERY="SELECT version();" # SQL-запрос (можно передавать аргументом)

# Если передан аргумент, используем его как запрос
if [[ ! -z "$1" ]]; then
    QUERY="$1"
fi

# Запуск запроса
PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "$QUERY"
