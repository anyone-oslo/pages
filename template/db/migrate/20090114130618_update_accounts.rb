# encoding: utf-8

class UpdateAccounts < ActiveRecord::Migration
	def self.up
		add_column :accounts, :is_activated, :boolean, :null => false, :default => '1'
		add_column :accounts, :domain, :string
		add_column :users,    :is_super_admin, :boolean, :null => false, :default => '0'
	end

	def self.down
		remove_column :accounts, :is_activated
		remove_column :accounts, :domain
		remove_column :users,    :is_super_admin
	end
end
