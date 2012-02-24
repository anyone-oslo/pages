class AddSmsFlag < ActiveRecord::Migration
	def self.up
		add_column :users, :sms_sender, :boolean
	end

	def self.down
		remove_column :users, :sms_sender
	end
end
