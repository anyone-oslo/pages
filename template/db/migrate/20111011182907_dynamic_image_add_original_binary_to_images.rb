# encoding: utf-8

class DynamicImageAddOriginalBinaryToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :original_binary_id, :integer
  end

  def self.down
    remove_column :images, :original_binary_id
  end
end
