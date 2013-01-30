# encoding: utf-8

class DropFeeds < ActiveRecord::Migration
  def self.up
    drop_table :feeds
    drop_table :feed_items
  end

  def self.down
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

  end
end
