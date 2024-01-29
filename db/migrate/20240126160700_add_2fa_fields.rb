# frozen_string_literal: true

class Add2faFields < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.boolean :otp_enabled, null: false, default: false
      t.string :otp_secret
      t.datetime :last_otp_at
      t.jsonb :hashed_recovery_codes, null: false, default: []
    end
  end
end
