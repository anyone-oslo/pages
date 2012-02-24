class RemoveAutopublishAt < ActiveRecord::Migration
	def self.up
		Page.find(:all, :conditions => ['autopublish = 1']).each do |page|
			page.update_attribute(:published_at, page.autopublish_at)
		end
		remove_column :pages, :has_been_published
		remove_column :pages, :autopublish_at
	end

	def self.down
		add_column :pages, :has_been_published, :boolean, :default => 0, :null => false
		add_column :pages, :autopublish_at, :datetime
	end
end
