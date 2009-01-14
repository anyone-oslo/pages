class CreateImages < ActiveRecord::Migration
	def self.up
		create_table :images do |t|
			t.column :title,        :string
			t.column :byline,       :string
			t.column :description,  :text
			t.column :filename,     :string
			t.column :content_type, :string
			t.column :folder,       :integer
			t.column :user_id,      :integer
			t.column :created_at,   :datetime
			t.column :filters,      :text
			t.column :size,         :string
			t.column :hotspot,      :string
			t.column :data,         :binary, :limit => 100.megabytes
		end

		create_table :cached_images do |t|
			t.column :image_id,     :integer
			t.column :filterset,    :string
			t.column :created_at,   :datetime
			t.column :ip,           :string
			t.column :size,         :string
			t.column :data,         :binary, :limit => 100.megabytes
			t.column :last_used_at, :datetime
		end
	end

	def self.down
		drop_table :images
		drop_table :cached_images
	end
end
