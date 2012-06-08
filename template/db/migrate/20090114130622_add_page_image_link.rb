class AddPageImageLink < ActiveRecord::Migration
	def self.up
		add_column :pages, :image_link, :string
		add_column :images, :url, :string
		create_table :images_pages, :id => false do |t|
			t.column :page_id, :integer
			t.column :image_id, :integer
		end
	end

	def self.down
		remove_column :pages, :image_link
		remove_column :images, :url
		drop_table :images_pages
	end
end
