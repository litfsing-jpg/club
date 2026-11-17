# frozen_string_literal: true

module ::ClubAccess
  class WebhooksController < ::ApplicationController
    requires_plugin ClubAccess::PLUGIN_NAME
    skip_before_action :verify_authenticity_token

    def receive
      # Валидация подписи вебхука
      secret = SiteSetting.club_access_webhook_secret
      if secret.present? && request.headers["X-Webhook-Secret"] != secret
        return render_json_error("Неверная подпись вебхука", status: 401)
      end

      email = params[:email].to_s.strip.downcase
      event = params[:event] # 'payment_succeeded', 'subscription_cancelled', 'order_paid'
      duration_days = (params[:duration_days] || 30).to_i

      user = User.find_by_email(email) || User.joins(:user_emails).find_by(user_emails: { email: email })

      unless user
        # Если пользователя еще нет, сохраняем отложенную подписку
        return render json: { status: "user_not_found_deferred", email: email }
      end

      subscription = ClubSubscription.find_or_initialize_by(user_id: user.id)
      subscription.external_email = email
      subscription.source_type = params[:source_type] || "webhook"

      case event
      when "payment_succeeded", "order_paid"
        subscription.status = :active
        current_expiry = subscription.valid_until && subscription.valid_until > Time.zone.now ? subscription.valid_until : Time.zone.now
        subscription.valid_until = current_expiry + duration_days.days
      when "subscription_cancelled", "refund"
        subscription.status = :cancelled
      end

      subscription.save!
      subscription.sync_user_group!

      render json: {
        success: true,
        user_id: user.id,
        status: subscription.status,
        valid_until: subscription.valid_until
      }
    end
  end
end

