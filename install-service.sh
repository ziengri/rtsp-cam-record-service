#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Использование: $0 <service-file> <instance-name>"
  echo "Пример: $0 cam-recorder@.service cam1"
  exit 1
fi

SERVICE_FILE="$1"
INSTANCE_NAME="$2"

if [[ ! -f "$SERVICE_FILE" ]]; then
  echo "Ошибка: файл '$SERVICE_FILE' не найден"
  exit 1
fi

SERVICE_BASENAME="$(basename "$SERVICE_FILE")"

if [[ "$SERVICE_BASENAME" != *@.service ]]; then
  echo "Ошибка: ожидается шаблонный unit вида something@.service"
  exit 1
fi

SERVICE_TEMPLATE_NAME="${SERVICE_BASENAME%.service}"
SERVICE_NAME="${SERVICE_TEMPLATE_NAME%@}"   # например cam-recorder

TARGET_PATH="/etc/systemd/system/$SERVICE_BASENAME"

echo "Копирую $SERVICE_FILE -> $TARGET_PATH"
cp "$SERVICE_FILE" "$TARGET_PATH"

echo "Перезагружаю systemd"
systemctl daemon-reload

echo "Включаю сервис ${SERVICE_NAME}@${INSTANCE_NAME}"
systemctl enable "${SERVICE_NAME}@${INSTANCE_NAME}"

echo "Запускаю сервис ${SERVICE_NAME}@${INSTANCE_NAME}"
systemctl start "${SERVICE_NAME}@${INSTANCE_NAME}"

echo "Статус:"
systemctl status "${SERVICE_NAME}@${INSTANCE_NAME}" --no-pager