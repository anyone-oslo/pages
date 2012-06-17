# encoding: utf-8

class AddNewsFlag < ActiveRecord::Migration
	def self.up
		add_column :pages, :news_page, :boolean, :null => false, :default => '0'
	end

	def self.down
		remove_column :pages, :news_page
	end
end
