# encoding: utf-8

class DropExtraBinaryColumns < ActiveRecord::Migration
	def self.up
		remove_column :binaries, :linkable_id
		remove_column :binaries, :linkable_type
	end

	def self.down
		add_column :binaries, :linkable_id,   :integer
		add_column :binaries, :linkable_type, :string
	end
end
