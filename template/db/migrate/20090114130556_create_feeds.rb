class CreateFeeds < ActiveRecord::Migration
	def self.up
		create_table :feeds do |t|
			t.column :url,          :string
			t.column :link,         :string
			t.column :title,        :string
			t.column :description,  :text
			t.column :refreshed_at, :datetime
		end

		create_table :feed_items do |t|
			t.column :feed_id,     :integer
			t.column :guid,        :string
			t.column :title,       :string
			t.column :link,        :string
			t.column :description, :text
			t.column :pubdate,     :datetime
		end
	end

	def self.down
		drop_table :feeds
		drop_table :feed_items
	end
end
