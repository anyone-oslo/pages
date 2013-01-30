# encoding: utf-8

class CreateUserLogins < ActiveRecord::Migration

  def self.up
    create_table :user_logins do |t|
      t.column :user_id,         :integer
      t.column :hashed_password, :string
      t.column :token,           :string
      t.column :remote_ip,       :string
      t.column :created_at,      :datetime
      t.column :last_used_at,    :datetime
    end
  end

  def self.down
    drop_table :user_logins
  end

end
