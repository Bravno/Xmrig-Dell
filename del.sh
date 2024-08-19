#!/bin/bash

set -e

# Определяем переменные
XMRIG_DIR="/usr/local/xmrig"
CONTROL_SCRIPT="/usr/local/bin/xmrig_control.sh"
CONFIG_FILE="/etc/xmrig/config.json"
DOCKER_IMAGE="xmrig-image"
DOCKER_CONTAINER="xmrig-container"

# Функция для вывода сообщения об ошибке и завершения скрипта
error_exit() {
    echo -e "\033[31m$1\033[0m"
    exit 1
}

# Удаление Docker контейнера и образа
echo "Удаление Docker контейнера и образа..."
if sudo docker ps -a | grep -q $DOCKER_CONTAINER; then
    sudo docker stop $DOCKER_CONTAINER || error_exit "Не удалось остановить контейнер $DOCKER_CONTAINER."
    sudo docker rm $DOCKER_CONTAINER || error_exit "Не удалось удалить контейнер $DOCKER_CONTAINER."
fi

if sudo docker images | grep -q $DOCKER_IMAGE; then
    sudo docker rmi $DOCKER_IMAGE || error_exit "Не удалось удалить образ $DOCKER_IMAGE."
fi

# Удаление Docker и Docker Compose
echo "Удаление Docker и Docker Compose..."
if sudo apt-get remove --purge -y docker-ce docker-ce-cli containerd.io; then
    echo "Docker удален."
else
    error_exit "Не удалось удалить Docker."
fi

if sudo rm /usr/local/bin/docker-compose; then
    echo "Docker Compose удален."
else
    error_exit "Не удалось удалить Docker Compose."
fi

# Удаление XMRig и связанных файлов
echo "Удаление XMRig и связанных файлов..."
if [ -d "$XMRIG_DIR" ]; then
    sudo rm -rf "$XMRIG_DIR" || error_exit "Не удалось удалить директорию XMRig."
fi

if [ -f "$CONTROL_SCRIPT" ]; then
    sudo rm "$CONTROL_SCRIPT" || error_exit "Не удалось удалить скрипт управления XMRig."
fi

if [ -f "$CONFIG_FILE" ]; then
    sudo rm "$CONFIG_FILE" || error_exit "Не удалось удалить конфигурационный файл XMRig."
fi

# Удаление crontab записи
echo "Удаление записи из crontab..."
if crontab -l | grep -v "$CONTROL_SCRIPT" | crontab -; then
    echo "Запись в crontab удалена."
else
    error_exit "Не удалось удалить запись из crontab."
fi

# Очистка ненужных пакетов
echo "Очистка ненужных пакетов..."
sudo apt-get autoremove -y || error_exit "Не удалось удалить ненужные пакеты."
sudo apt-get clean || error_exit "Не удалось очистить кеш пакетов."

echo "Удаление завершено."
