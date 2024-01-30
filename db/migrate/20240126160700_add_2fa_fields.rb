# frozen_string_literal: true

class Add2faFields < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.boolean :otp_enabled, null: false, default: false
      t.string :otp_secret
      t.datetime :last_otp_at
      t.jsonb :hashed_recovery_codes, null: false, default: []
      t.string :session_token
    end

    rename_column :users, :hashed_password, :password_digest

    reversible do |dir|
      dir.up do
        User.find_each { |u| u.update(session_token: SecureRandom.hex(32)) }
        change_column_null :users, :session_token, false
      end
    end
  end
end
