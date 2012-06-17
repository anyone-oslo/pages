# encoding: utf-8

class CreateUsers < ActiveRecord::Migration
	def self.up
		create_table :users do |t|
			t.column :username,        :string
			t.column :hashed_password, :string
			t.column :realname,        :string
			t.column :email,           :string
			t.column :lastlogin_at,    :datetime
			t.column :created_by,      :integer
			t.column :created_at,      :datetime
			t.column :admin,           :boolean
			t.column :persistent_data, :text
		end
	end

	def self.down
		drop_table :users
	end
end
