#!/usr/bin/env bash
set -e

echo "=== Инициализация Discourse для ИИ Клуба ==="

# Проверка наличия docker compose
if ! command -v docker &> /dev/null; then
    echo "Ошибка: Docker не установлен."
    exit 1
fi

echo "1. Запуск вспомогательных сервисов (PostgreSQL, Redis)..."
docker compose up -d postgres redis

echo "2. Ожидание готовности базы данных..."
until docker compose exec postgres pg_isready -U discourse; do
  echo "Ожидание PostgreSQL..."
  sleep 2
done

echo "3. Запуск контейнера приложения Discourse..."
docker compose up -d app

echo "4. Применение миграций и посев начальных категорий..."
docker compose exec app bundle exec rake db:migrate
docker compose exec app bundle exec rails runner /var/www/discourse/scripts/seed_categories.rb

echo "=== Инициализация успешно завершена! Портал доступен на http://localhost:3000 ==="
