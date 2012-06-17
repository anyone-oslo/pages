# encoding: utf-8

class CreateTextbits < ActiveRecord::Migration
	def self.up
		create_table :textbits do |t|
			t.column :textable_id,   :integer
			t.column :textable_type, :string
			t.column :name,          :string
			t.column :language,      :string
			t.column :filter,        :string
			t.column :body,          :text
			t.column :created_at,    :datetime
			t.column :updated_at,    :datetime
		end
	end

	def self.down
		drop_table :textbits
	end
end
