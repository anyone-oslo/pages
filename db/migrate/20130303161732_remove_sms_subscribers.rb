# encoding: utf-8

class RemoveSmsSubscribers < ActiveRecord::Migration
  def self.up
    drop_table :sms_subscribers
  end

  def self.down
    create_table "sms_subscribers" do |t|
      t.string   "msisdn"
      t.string   "group", :default => "Default"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
