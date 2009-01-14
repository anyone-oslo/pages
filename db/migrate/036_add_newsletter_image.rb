class AddNewsletterImage < ActiveRecord::Migration
	def self.up
		add_column :mailouts, :image_id, :integer
	end

	def self.down
		remove_column :mailouts, :image_id
	end
end
