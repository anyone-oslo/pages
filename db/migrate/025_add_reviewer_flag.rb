class AddReviewerFlag < ActiveRecord::Migration
	def self.up
		add_column :users, :is_reviewer, :boolean, :null => false, :default => '0'
	end

	def self.down
		remove_column :users, :is_reviewer
	end
end
