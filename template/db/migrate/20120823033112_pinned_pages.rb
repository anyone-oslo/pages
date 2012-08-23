# encoding: utf-8

class PinnedPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :pinned, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :pages, :pinned
  end
end
