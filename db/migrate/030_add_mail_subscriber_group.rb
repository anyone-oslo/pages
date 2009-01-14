class AddMailSubscriberGroup < ActiveRecord::Migration
	def self.up
		add_column :mail_subscribers, :group, :string, :default => 'Default'
	end

	def self.down
		remove_column :mail_subscribers, :group
	end
end
