#!/bin/bash

REPO_DIR="$HOME/my-site"
WEB_DIR="/var/www/html"
LOG_FILE="$HOME/deploy.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

fail() {
  log "ОШИБКА: $1"
  exit 1
}



cd "$REPO_DIR" || fail "нет каталога $REPO_DIR"
git fetch || fail "git fetch не удался"

if [ "$(git rev-parse HEAD)" = "$(git rev-parse @{u})" ]; then
  exit 0
fi

log "Найдены новые коммиты, начало деплоя"

git pull || fail "git pull не удался"

cp "$REPO_DIR"/*.html "$WEB_DIR"/ || fail "не удалось скопировать файлы"

sudo nginx -t || fail "ошибка в конфигурации nginx, перезагрузка отменена"
sudo systemctl reload nginx || fail "не удалось перезагрузить nginx"

log "Деплой успешен"
