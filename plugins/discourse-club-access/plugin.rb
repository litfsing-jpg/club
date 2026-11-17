# frozen_string_literal: true

# name: discourse-club-access
# about: Модуль доступа в клуб, проверки подписок и интеграции с платёжными системами (GetCourse, Prodamus, Stripe)
# version: 1.0.0
# authors: Antigravity Team
# url: https://github.com/iiclub/discourse-club-access

enabled_site_setting :club_access_enabled

register_asset "stylesheets/club-access.scss"

after_initialize do
  module ::ClubAccess
    PLUGIN_NAME = "discourse-club-access"

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace ClubAccess
    end
  end

  require_relative "app/models/club_subscription"
  require_relative "app/controllers/club_access/account_controller"
  require_relative "app/controllers/club_access/webhooks_controller"

  ClubAccess::Engine.routes.draw do
    get "/account" => "account#index"
    post "/verify-email" => "account#verify_email"
    post "/confirm-code" => "account#confirm_code"
    post "/webhooks/payment" => "webhooks#receive"
  end

  Discourse::Application.routes.append do
    mount ::ClubAccess::Engine, at: "/forum/club"
    mount ::ClubAccess::Engine, at: "/club"
  end
end

