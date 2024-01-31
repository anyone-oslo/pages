# frozen_string_literal: true

class ChangeEmailToCitext < ActiveRecord::Migration[7.0]
  def up
    enable_extension "citext"
    %i[users invites].each do |t|
      change_column t, :email, :citext
      add_index t, :email, unique: true, name: "index_#{t}_on_email"
    end
  end

  def down
    change_column :users, :email, :string
    remove_index :users, name: "index_users_on_email"
    %i[users invites].each do |t|
      change_column t, :email, :string
      remove_index t, name: "index_#{t}_on_email"
    end
  end
end
