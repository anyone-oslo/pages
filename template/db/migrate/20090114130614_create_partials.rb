class CreatePartials < ActiveRecord::Migration
	def self.up
		
		# Modify fragments table
		remove_column :page_fragments, :name
		remove_column :page_fragments, :description
		remove_column :page_fragments, :author_id
		rename_column :page_fragments, :slug, :name
		rename_table  :page_fragments, :partials
		
		# Change textbits
		Textbit.update_all "textable_type = 'Partial'", "textable_type = 'PageFragment'"
		
	end

	def self.down
		rename_table :partials, :page_fragments
		rename_column :page_fragments, :name, :slug
		add_column :page_fragments, :name, :string
		add_column :page_fragments, :author_id, :integer
		add_column :page_fragments, :description, :text

		Textbit.update_all "textable_type = 'PageFragment'", "textable_type = 'Partial'"
	end
end
