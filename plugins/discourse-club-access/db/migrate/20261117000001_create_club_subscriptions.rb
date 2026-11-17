# frozen_string_literal: true

class CreateClubSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :club_subscriptions do |t|
      t.integer :user_id, null: false, index: { unique: true }
      t.string :external_email, null: false, index: true
      t.string :source_type, default: "manual"
      t.integer :status, default: 0, null: false
      t.datetime :valid_until
      t.timestamps
    end
  end
end

