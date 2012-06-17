# encoding: utf-8

class ImageUpdatedAt < ActiveRecord::Migration
	def self.up
		add_column :images, :updated_at, :datetime
		Image.update_all('updated_at = created_at')
	end

	def self.down
		remove_column :images, :updated_at
	end
end
