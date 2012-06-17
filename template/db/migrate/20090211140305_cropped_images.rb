# encoding: utf-8

class CroppedImages < ActiveRecord::Migration
	def self.up
		add_column :images, :cropped, :boolean, :null => false, :default => false
		add_column :images, :crop_start, :string
		add_column :images, :crop_size,  :string
		rename_column :images, :size, :original_size
	end

	def self.down
		remove_column :images, :cropped, :boolean, :null => false, :default => false
		remove_column :images, :crop_start, :string
		remove_column :images, :crop_size,  :string
		rename_column :images, :original_size, :size
	end
end
