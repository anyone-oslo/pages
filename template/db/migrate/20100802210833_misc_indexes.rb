# encoding: utf-8

class MiscIndexes < ActiveRecord::Migration
  def self.up
    add_index :feeds, :url
    add_index :feed_items, :feed_id
    add_index :tags, :name
    add_index :taggings, [:taggable_type, :taggable_id], :name => 'by_taggable'
    add_index :taggings, [:tag_id], :name => 'by_tag_id'
  end

  def self.down
    remove_index :feeds, :url
    remove_index :feed_items, :feed_id
    remove_index :tags, :name
    remove_index :taggings, :name => 'by_taggable'
    remove_index :taggings, :name => 'by_tag_id'
  end
end
