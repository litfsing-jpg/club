# Скрипт посева категорий Discourse для «ИИ Клуба»
# Запуск: rails runner scripts/seed_categories.rb

puts "=== Посев структуры категорий ИИ Клуба ==="

admin_user = User.find_by(username: "system") || User.first

# 1. Создаем группу участников клуба
club_group = Group.find_or_create_by!(name: "club_members") do |g|
  g.visibility_level = Group.visibility_levels[:public]
  g.title = "Участник клуба"
  g.primary_group = true
end
puts "Группа #{club_group.name} создана/проверена."

categories = [
  # Публичные категории (видны всем)
  {
    name: "Журнал",
    slug: "journal",
    color: "0088CC",
    text_color: "FFFFFF",
    description: "Альманахи обновлений, статьи и дайджесты клуба.",
    permissions: { everyone: :readonly }
  },
  {
    name: "Доступ к клубу",
    slug: "club-access",
    color: "25AAE2",
    text_color: "FFFFFF",
    description: "Инструкция по входу, подписке и подтверждению аккаунта.",
    permissions: { everyone: :readonly }
  },
  # Приватные категории (только для членов клуба)
  {
    name: "Анонсы",
    slug: "announcements",
    color: "E45735",
    text_color: "FFFFFF",
    description: "Анонсы ближайших эфиров, релизов и клубных мероприятий.",
    permissions: { "club_members" => :readonly }
  },
  {
    name: "Полезняки",
    slug: "resources",
    color: "0E76BD",
    text_color: "FFFFFF",
    description: "Промпты, шаблоны, инструкции и проверенные инструменты.",
    permissions: { "club_members" => :full }
  },
  {
    name: "Саммари чатов",
    slug: "chat-summaries",
    color: "ED207B",
    text_color: "FFFFFF",
    description: "Выжимки и ключевые инсайты из тематических чатов.",
    permissions: { "club_members" => :full }
  },
  {
    name: "Записи эфиров",
    slug: "recordings",
    color: "F1592A",
    text_color: "FFFFFF",
    description: "Архив прошедших вебинаров, воркшопов и разборов.",
    permissions: { "club_members" => :full }
  }
]

categories.each do |cat_data|
  cat = Category.find_or_create_by!(slug: cat_data[:slug]) do |c|
    c.name = cat_data[:name]
    c.user = admin_user
    c.color = cat_data[:color]
    c.text_color = cat_data[:text_color]
    c.description = cat_data[:description]
  end

  # Настройка прав доступа
  cat.set_permissions!(cat_data[:permissions])
  cat.save!
  puts "Категория: #{cat.name} (slug: #{cat.slug}) настроена."
end

puts "=== Посев категорий завершен! ==="
