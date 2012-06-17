# encoding: utf-8

class AddIndexes < ActiveRecord::Migration
	def self.up
		add_index( :textbits, [ :textable_id, :textable_type ], :name => :by_association )
		add_index( :textbits, [ :textable_id, :textable_type, :name, :language ], :name => :by_foreign_key, :unique => true )
		add_index( :pages, [ :status, :parent_page_id, :position ], :name => :for_find_page )
		add_index :pages, :status
		add_index :pages, :user_id
		add_index :pages, :parent_page_id
		add_index :pages, :position
	end

	def self.down
		remove_index :textbits, :name => :by_association
		remove_index :textbits, :name => :by_foreign_key
		remove_index :pages, :name => :for_find_page
		remove_index :pages, :status
		remove_index :pages, :user_id
		remove_index :pages, :parent_page_id
		remove_index :pages, :position
	end
end
