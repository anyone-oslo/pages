# encoding: utf-8

class ImageTitleToName < ActiveRecord::Migration
  def self.up
    rename_column :images, :title, :name
  end

  def self.down
    rename_column :images, :name, :title
  end
end
