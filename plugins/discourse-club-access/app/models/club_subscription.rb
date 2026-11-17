# frozen_string_literal: true

module ::ClubAccess
  class ClubSubscription < ::ActiveRecord::Base
    self.table_name = "club_subscriptions"

    belongs_to :user

    enum status: { pending: 0, active: 1, expired: 2, cancelled: 3 }

    validates :external_email, presence: true
    validates :user_id, uniqueness: true

    def active?
      status == "active" && (valid_until.nil? || valid_until > Time.zone.now)
    end

    def sync_user_group!
      group_name = SiteSetting.club_access_group_name
      group = Group.find_by(name: group_name)
      return unless group && user

      if active?
        group.add(user) unless group.users.include?(user)
      else
        group.remove(user) if group.users.include?(user)
      end
    end
  end
end

