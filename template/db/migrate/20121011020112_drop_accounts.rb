# encoding: utf-8

class DropAccounts < ActiveRecord::Migration
  def self.up
    drop_table :accounts
  end

  def self.down
    create_table :accounts do |t|
      t.string   :name
      t.string   :plan
      t.string   :key
      t.text     :billing_address
      t.integer  :account_holder_id
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :last_billed_at
      t.boolean  :is_activated, :default => true, :null => false
      t.string   :domain
    end
  end
end
