class CreateAlbums < ActiveRecord::Migration
	def self.up

		create_table :albums do |t|
			t.column :name,       :string
			t.column :parent_id,  :integer
			t.column :image_id,   :integer
			t.column :created_at, :datetime
			t.column :updated_at, :datetime
		end

		create_table :album_images do |t|
			t.column :album_id, :integer
			t.column :image_id, :integer
			t.column :position, :integer
			t.column :created_at, :datetime
		end
	end

	def self.down
		drop_table :albums
		drop_table :album_images
	end
end
