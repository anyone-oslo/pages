# encoding: utf-8

class MailingInProgress < ActiveRecord::Migration
	def self.up
		add_column :mailings, :in_progress, :boolean, :null => false, :default => false
	end

	def self.down
		remove_column :mailings, :in_progress
	end
end
