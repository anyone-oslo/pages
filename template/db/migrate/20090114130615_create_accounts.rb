# encoding: utf-8

class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.column :name,              :string
      t.column :plan,              :string
      t.column :key,               :string
      t.column :billing_address,   :text
      t.column :account_holder_id, :integer
      t.column :created_at,        :datetime
      t.column :updated_at,        :datetime
      t.column :last_billed_at,    :datetime
    end
  end

  def self.down
    drop_table :accounts
  end
end
