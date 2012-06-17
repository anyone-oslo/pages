# encoding: utf-8

class CreatePageFragments < ActiveRecord::Migration
	def self.up
		create_table :page_fragments do |t|
			t.column :name,        :string
			t.column :slug,        :string
			t.column :description, :text
			t.column :author_id,   :integer
			t.column :created_at,  :datetime
			t.column :updated_at,  :datetime
		end
	end

	def self.down
		drop_table :page_fragments
	end
end
