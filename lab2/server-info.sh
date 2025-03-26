#!/bin/bash

OUTPUT_FILE="/home/lab2/results/server_info.txt"

echo "Сбор данных о сервере..." | tee "$OUTPUT_FILE"

# 1. Список запущенных процессов
echo -e "\n=== Список запущенных процессов ===" | tee -a "$OUTPUT_FILE"
ps aux | tee -a "$OUTPUT_FILE"

# 2. Активные сетевые соединения
echo -e "\n=== Активные сетевые соединения ===" | tee -a "$OUTPUT_FILE"
ss -tulnp | tee -a "$OUTPUT_FILE"

# 3. Список файлов в каталогах пользователей (/home/)
echo -e "\n=== Список файлов в каталогах пользователей (/home/) ===" | tee -a "$OUTPUT_FILE"
find /home/ -type f | tee -a "$OUTPUT_FILE"

# 4. Сетевые интерфейсы
echo -e "\n=== Сетевые интерфейсы ===" | tee -a "$OUTPUT_FILE"
ip a | tee -a "$OUTPUT_FILE"

# 5. Таблица маршрутизации
echo -e "\n=== Таблица маршрутизации ===" | tee -a "$OUTPUT_FILE"
ip route | tee -a "$OUTPUT_FILE"

# 6. Список пользователей системы
echo -e "\n=== Список пользователей системы ===" | tee -a "$OUTPUT_FILE"
cut -d: -f1 /etc/passwd | tee -a "$OUTPUT_FILE"

echo -e "\nДанные сохранены в $OUTPUT_FILE"
