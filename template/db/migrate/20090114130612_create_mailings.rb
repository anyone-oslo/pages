# encoding: utf-8

class CreateMailings < ActiveRecord::Migration
	def self.up
		create_table :mailings do |t|
			t.column :recipients, :string
			t.column :sender, :string
			t.column :subject, :string
			t.column :body, :text
			t.column :created_at, :datetime
			t.column :failed, :boolean, :default => false
		end
	end

	def self.down
		drop_table :mailings
	end
end
