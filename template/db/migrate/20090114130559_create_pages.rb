# encoding: utf-8

class CreatePages < ActiveRecord::Migration
	def self.up
		create_table :pages do |t|
			t.column :parent_page_id, :integer
			t.column :position,       :integer
			t.column :byline,         :string
			t.column :template,       :string
			t.column :created_at,     :datetime
			t.column :updated_at,     :datetime
			t.column :user_id,        :integer
			t.column :status,         :integer, :null => false, :default => 0
			t.column :content_order,  :string
			t.column :feed_enabled,   :boolean, :null => false, :default => 0
		end
	end

	def self.down
		drop_table :pages
	end
end
