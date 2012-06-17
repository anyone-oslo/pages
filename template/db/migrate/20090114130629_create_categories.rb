# encoding: utf-8

class CreateCategories < ActiveRecord::Migration
	def self.up
		create_table :categories do |t|
			t.string  :name, :slug
			t.integer :position
			t.timestamps
		end
	    add_index :categories, [:slug]
		create_table :pages_categories, :id => false do |t|
			t.column :page_id, :integer
			t.column :category_id, :integer
	    end
	    add_index :pages_categories, [:page_id]
	    add_index :pages_categories, [:category_id]
	end

	def self.down
		drop_table :pages_categories
		drop_table :categories
	end
end
