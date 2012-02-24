class CreateEvents < ActiveRecord::Migration
	def self.up
		create_table :events do |t|
			t.column :name,     :string
			t.column :location, :string
			t.column :start_on, :date
			t.column :end_on,   :date
		end
	end

	def self.down
		drop_table :events
	end
end
