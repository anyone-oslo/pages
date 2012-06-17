# encoding: utf-8

class CreateImagesets < ActiveRecord::Migration
	def self.up
		create_table :imagesets do |t|
			t.column :name,        :string
			t.column :description, :text
			t.column :created_at,  :datetime
			t.column :user_id,     :integer
		end

		create_table :images_imagesets do |t|
			t.column :relation_id, :integer
			t.column :imageset_id, :integer
			t.column :image_id,    :integer
			t.column :position,    :integer
		end
	end

	def self.down
		drop_table :imagesets
		drop_table :images_imagesets
	end
end
