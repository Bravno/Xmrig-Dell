#!/bin/bash

# Задаем переменные
XMRIG_VERSION="6.15.0"
XMRIG_DIR="/usr/local/xmrig"
XMRIG_BIN="$XMRIG_DIR/xmrig"
CONTROL_SCRIPT="/usr/local/bin/xmrig_control.sh"
CONFIG_FILE="/etc/xmrig/config.json"
SERVICE_FILE="/etc/systemd/system/xmrig.service"

# Остановка и отключение системного сервиса XMRig
if systemctl is-active --quiet xmrig; then
    sudo systemctl stop xmrig
    sudo systemctl disable xmrig
fi

# Удаление системного сервиса XMRig
if [ -f $SERVICE_FILE ]; then
    sudo rm $SERVICE_FILE
    sudo systemctl daemon-reload
fi

# Удаление XMRig бинарного файла
if [ -f $XMRIG_BIN ]; then
    sudo rm $XMRIG_BIN
fi

# Удаление директории XMRig
if [ -d $XMRIG_DIR ]; then
    sudo rmdir $XMRIG_DIR
fi

# Удаление конфигурационного файла
if [ -f $CONFIG_FILE ]; then
    sudo rm $CONFIG_FILE
fi

# Удаление скрипта управления XMRig
if [ -f $CONTROL_SCRIPT ]; then
    sudo rm $CONTROL_SCRIPT
fi

# Удаление записи из crontab
(crontab -l 2>/dev/null | grep -v "$CONTROL_SCRIPT") | crontab -

echo "XMRig полностью удален."
