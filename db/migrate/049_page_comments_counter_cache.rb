class PageCommentsCounterCache < ActiveRecord::Migration
	def self.up
		add_column :pages, :comments_count, :integer, :null => false, :default => 0
		add_column :pages, :last_comment_at, :datetime
		# Add counts
		Page.find(:all).each do |page|
			if page.comments.length > 0
				page.fix_counter_cache!
				page.update_attribute(:last_comment_at, page.comments.last.created_at)
			end
		end
	end

	def self.down
		remove_column :pages, :comments_count
		remove_column :pages, :last_comment_at
	end
end
