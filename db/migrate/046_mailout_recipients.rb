class MailoutRecipients < ActiveRecord::Migration
	def self.up
		add_column :mailouts, :groups, :text
		add_column :mailouts, :host, :string
	end

	def self.down
		remove_column :mailouts, :groups
		remove_column :mailouts, :host
	end
end
