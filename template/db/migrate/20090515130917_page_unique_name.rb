class PageUniqueName < ActiveRecord::Migration
	def self.up
		add_column :pages, :unique_name, :string
	end

	def self.down
		remove_column :pages, :unique_name
	end
end
