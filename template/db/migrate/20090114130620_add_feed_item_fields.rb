# encoding: utf-8

class AddFeedItemFields < ActiveRecord::Migration
  def self.up
    add_column :feed_items, :author, :string
  end

  def self.down
    remove_column :feed_items, :author
  end
end
