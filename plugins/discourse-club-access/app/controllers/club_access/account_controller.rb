# frozen_string_literal: true

module ::ClubAccess
  class AccountController < ::ApplicationController
    requires_plugin ClubAccess::PLUGIN_NAME
    before_action :ensure_logged_in

    def index
      subscription = ClubSubscription.find_by(user_id: current_user.id)

      render json: {
        user: {
          id: current_user.id,
          username: current_user.username,
          email: current_user.email
        },
        subscription: subscription ? {
          status: subscription.status,
          is_active: subscription.active?,
          valid_until: subscription.valid_until,
          external_email: subscription.external_email,
          source_type: subscription.source_type
        } : nil,
        verification_options: {
          getcourse_sso_url: "#{SiteSetting.club_access_getcourse_url}/sso/discourse?return_to=/club/account",
          can_verify_by_email: true
        }
      }
    end

    def verify_email
      email = params[:email].to_s.strip.downcase
      if email.blank? || !EmailValidator.valid?(email)
        return render_json_error("Укажите корректный email адрес покупки.")
      end

      # Генерация 6-значного проверочного кода
      code = SecureRandom.random_number(100_000..999_999).to_s
      Discourse.redis.setex("club_access_code:#{current_user.id}:#{email}", 15.minutes.to_i, code)

      # В реальной отправке используется EmailSender / Notification
      # Для локального тестирования код пишется в лог
      Rails.logger.info("[ClubAccess] Verification code for #{email}: #{code}")

      render json: {
        success: true,
        message: "Проверочный код отправлен на указанную почту."
      }
    end

    def confirm_code
      email = params[:email].to_s.strip.downcase
      code = params[:code].to_s.strip

      saved_code = Discourse.redis.get("club_access_code:#{current_user.id}:#{email}")
      if saved_code.blank? || saved_code != code
        return render_json_error("Неверный или устаревший проверочный код.")
      end

      # Код верен - привязываем подписку
      subscription = ClubSubscription.find_or_initialize_by(user_id: current_user.id)
      subscription.external_email = email
      subscription.source_type = "email_verification"
      subscription.status = :active
      subscription.valid_until = 1.month.from_now
      subscription.save!
      subscription.sync_user_group!

      Discourse.redis.del("club_access_code:#{current_user.id}:#{email}")

      render json: {
        success: true,
        message: "Подписка успешно подтверждена! Доступ к клубу открыт.",
        valid_until: subscription.valid_until
      }
    end
  end
end
