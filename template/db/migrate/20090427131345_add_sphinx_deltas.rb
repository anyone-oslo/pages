class AddSphinxDeltas < ActiveRecord::Migration
	def self.up
		add_column :pages, :delta, :boolean, :null => false, :default => false
		add_column :users, :delta, :boolean, :null => false, :default => false
		add_index :pages, :delta, :name => 'delta_index'
		add_index :users, :delta, :name => 'delta_index'
	end

	def self.down
		remove_column :pages, :delta
		remove_column :users, :delta
	end
end
