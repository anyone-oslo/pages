class MailingContentType < ActiveRecord::Migration
	def self.up
		add_column :mailings, :content_type, :string
	end

	def self.down
		remove_column :mailings, :content_type
	end
end
