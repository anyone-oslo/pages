class PageHasBeenPublished < ActiveRecord::Migration
	def self.up
		add_column :pages, :has_been_published, :boolean, :default => 0, :null => false
		Page.update_all('has_been_published = 1', 'status > 1 AND autopublish = 0')
	end

	def self.down
		remove_column :pages, :has_been_published
	end
end
