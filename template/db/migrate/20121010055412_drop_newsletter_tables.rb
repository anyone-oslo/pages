# encoding: utf-8

class DropNewsletterTables < ActiveRecord::Migration
  def self.up
    drop_table :mail_subscribers
    drop_table :mailouts
    drop_table :mailings
  end

  def self.down
    create_table :mail_subscribers do |t|
      t.string   :email
      t.datetime :created_at
      t.string   :group,      :default => "Default"
    end
    create_table :mailings do |t|
      t.string   :recipients
      t.string   :sender
      t.string   :subject
      t.text     :body
      t.datetime :created_at
      t.boolean  :failed,       :default => false
      t.string   :content_type
      t.boolean  :in_progress,  :default => false, :null => false
    end
    create_table :mailouts do |t|
      t.string   :subject
      t.string   :sender
      t.string   :template
      t.text     :body
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :image_id
      t.text     :groups
      t.string   :host
    end
  end
end
