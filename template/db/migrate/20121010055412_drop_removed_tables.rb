# encoding: utf-8

class DropRemovedTables < ActiveRecord::Migration
  def self.up
    drop_table :mail_subscribers
    drop_table :mailouts
    drop_table :mailings
    drop_table :feeds
    drop_table :feed_items
    drop_table :accounts
    drop_table :partials
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

    create_table :feed_items do |t|
      t.integer  :feed_id
      t.string   :guid
      t.string   :title
      t.string   :link
      t.text     :description
      t.datetime :pubdate
      t.string   :author
    end
    add_index :feed_items, [:feed_id], :name => :index_feed_items_on_feed_id

    create_table :feeds do |t|
      t.string   :url
      t.string   :link
      t.string   :title
      t.text     :description
      t.datetime :refreshed_at
    end
    add_index :feeds, [:url], :name => :index_feeds_on_url

    create_table :accounts do |t|
      t.string   :name
      t.string   :plan
      t.string   :key
      t.text     :billing_address
      t.integer  :account_holder_id
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :last_billed_at
      t.boolean  :is_activated, :default => true, :null => false
      t.string   :domain
    end

    create_table :partials do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
