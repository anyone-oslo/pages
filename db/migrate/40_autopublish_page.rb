class AutopublishPage < ActiveRecord::Migration
	def self.up
		add_column :pages, :autopublish,    :boolean, :null => false, :default => 0
		add_column :pages, :autopublish_at, :datetime
	end

	def self.down
	end
end
