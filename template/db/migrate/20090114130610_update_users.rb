class UpdateUsers < ActiveRecord::Migration
	def self.up
		add_column    :users, :is_activated, :boolean, :null => false, :default => '0'
		add_column    :users, :is_deleted, :boolean, :null => false, :default => '0'
		rename_column :users, :admin, :is_admin
		add_column    :users, :token, :string
		add_column    :users, :born_on, :date
		add_column    :users, :mobile, :string
		add_column    :users, :web_link, :string
		add_column    :users, :image_id, :integer
		rename_column :users, :lastlogin_at, :last_login_at
	end

	def self.down
		remove_column :users, :is_activated
		remove_column :users, :is_deleted
		rename_column :users, :is_admin, :admin
		remove_column :users, :token
		remove_column :users, :born_on
		remove_column :users, :mobile
		remove_column :users, :web_link
		remove_column :users, :image_id
		rename_column :users, :last_login_at, :lastlogin_at
	end
end
