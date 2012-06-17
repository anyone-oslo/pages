# encoding: utf-8

class CreateBinaries < ActiveRecord::Migration
	def self.up
		create_table :binaries do |t|
			t.column :data,          :binary, :limit => 100.megabytes
			t.column :linkable_id,   :integer
			t.column :linkable_type, :string
		end
	end

	def self.down
		drop_table :binaries
	end
end
