# encoding: utf-8

class AddPageImage < ActiveRecord::Migration
  def self.up
    add_column :pages, :image_id, :integer
  end

  def self.down
    remove_column :pages, :image_id
  end
end
