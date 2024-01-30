# frozen_string_literal: true

class RemovePasswordResetTokens < ActiveRecord::Migration[7.0]
  def change
    drop_table :password_reset_tokens do |t|
      t.integer :user_id
      t.string :token
      t.datetime :expires_at
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
