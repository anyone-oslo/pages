class RemoveUserLogins < ActiveRecord::Migration

	def self.up
		drop_table :user_logins
	end

	def self.down
		create_table :user_logins do |t|
			t.column :user_id,         :integer
			t.column :hashed_password, :string
			t.column :token,           :string
			t.column :remote_ip,       :string
			t.column :created_at,      :datetime
			t.column :last_used_at,    :datetime
		end
	end

end