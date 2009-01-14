class CreateSmsSubscriber < ActiveRecord::Migration
	def self.up
		create_table :sms_subscribers do |t|
			t.column :msisdn, :string
			t.column :group, :string, :default => 'Default'
			t.column :created_at, :datetime
			t.column :updated_at, :datetime
		end
	end

	def self.down
		drop_table :sms_subscribers
	end
end
