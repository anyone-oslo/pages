# encoding: utf-8

class DropCachedDynamicImages < ActiveRecord::Migration
	def self.up
		drop_table :cached_images
	end

	def self.down
		create_table :cached_images do |t|
			t.column :image_id,   :integer
			t.column :filterset,  :string
			t.column :size,       :string
			t.column :created_at, :datetime
			t.column :updated_at, :datetime
			t.column :data,       :binary, :limit => 100.megabytes
		end
	end
end
