# encoding: utf-8

class CreateMailSubscribers < ActiveRecord::Migration
  def self.up
    create_table :mail_subscribers do |t|
      t.column :email,      :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :mail_subscribers
  end
end
