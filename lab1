#!/bin/bash

# Лог-файл
LOG_FILE="/var/log/script.log"

# Проверяем, что скрипт запущен от имени root
if [ "$EUID" -ne 0 ]; then
  echo "root required"
  exit 1
fi

echo "==== Начало работы скрипта ===="

# === Логирование первой части ===
echo "==== Начало первой части скрипта ===="

echo "Конфигурируем сеть..."
{
  # Конфигурация сети
  cat > /etc/network/interfaces <<EOL
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

# Основной интерфейс для подключения к сети
allow-hotplug enp0s3
iface enp0s3 inet dhcp

# Конфигурация шлюза внутренней сети
allow-hotplug enp0s8
iface enp0s8 inet static
address           192.168.1.1
netmask           255.255.255.0
network           192.168.1.0
dns-nameservers   77.88.8.1 8.8.8.8
EOL

  # Включаем интерфейс шлюза
  ifup enp0s8
} >> "$LOG_FILE" 2>&1

echo "Устанавливаем iptables и зависимости..."
{
  apt-get install iptables-persistent netfilter-persistent gcc -y
} >> "$LOG_FILE" 2>&1

echo "Добавляем правило NAT..."
{
  iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
  iptables-save
  netfilter-persistent save
} >> "$LOG_FILE" 2>&1

echo "Включаем IP форвардинг..."
{
  sysctl -w net.ipv4.ip_forward="1"
  sysctl -p
} >> "$LOG_FILE" 2>&1

echo "Настраиваем DNS..."
{
  apt install -y bind9 bind9utils swaks
} >> "$LOG_FILE" 2>&1

echo "Устанавливаем DHCP сервер..."
{
  DEBIAN_FRONTEND=noninteractive apt install -y isc-dhcp-server
  if [ $? -ne 0 ]; then
    echo "Ошибка при установке isc-dhcp-server"
  else
    echo "DHCP сервер установлен успешно"
  fi
} >> "$LOG_FILE" 2>&1

echo "Конфигурируем DHCP..."
{
  cat > /etc/default/isc-dhcp-server <<EOL
INTERFACESv4="enp0s8"
INTERFACESv6=""
EOL

  cat > /etc/dhcp/dhcpd.conf <<EOL
option domain-name "WORKGROUP";
option domain-name-servers 8.8.8.8;
default-lease-time 600;
max-lease-time 7200;
subnet 192.168.1.0 netmask 255.255.255.0
{
    range                       192.168.1.10 192.168.1.20;
    option broadcast-address    192.168.1.255;
    option routers              192.168.1.1;
    option domain-name-servers  8.8.8.8;
}
EOL
} >> "$LOG_FILE" 2>&1

echo "Запускаем DHCP-сервер..."
{
  /etc/init.d/isc-dhcp-server start
} >> "$LOG_FILE" 2>&1

echo "==== Завершение первой части скрипта ===="
echo "Первая часть завершена. Лог сохранён в $LOG_FILE"

echo "Переход ко второй части..."

# === Часть 2 ===
echo "==== Начало второй части скрипта ===="

# Задание по созданию программы на C
echo "Компилируем программу на C..."
gcc -o app lab1.c
chmod +x app

# Ввод значений
read -p "Введите первое число: " num1
read -p "Введите второе число: " num2

# Запуск программы с забранными значениями
./app $num1 $num2

echo "==== Завершение скрипта ===="
