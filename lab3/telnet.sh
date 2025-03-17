#!/usr/bin/expect -f

# === Параметры ===
set TELNET_HOST "192.168.0.117"   ;# IP-адрес удаленного хоста
set TELNET_PORT "23"              ;# Порт Telnet, по умолчанию 23
set TELNET_USER "labuser"         ;# Имя пользователя для подключения
set TELNET_PASS "7145"            ;# Пароль пользователя для подключения

# === Проверка прав ===
if {[catch {exec whoami} result]} {
    puts "Этот скрипт нужно запускать с правами sudo!"
    exit 1
}

# === Подключение через Telnet ===
spawn telnet $TELNET_HOST $TELNET_PORT

# Ожидание приглашения на ввод логина
expect "login: "
send "$TELNET_USER\r"

# Ожидание приглашения на ввод пароля
expect "Password: "
send "$TELNET_PASS\r"

# Ожидание, что сессия откроется
expect "$ "

# Выполнение команды
send "neofetch\r"

# Закрытие сессии
expect "$ "
send "exit\r"


# Завершение скрипта
expect eof
puts "✅ Подключение через Telnet завершено!"
