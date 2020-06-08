# frozen_string_literal: true

class RemoveSmsSubscribers < ActiveRecord::Migration[4.2]
  def self.up
    drop_table :sms_subscribers
  end

  def self.down
    create_table "sms_subscribers" do |t|
      t.string "msisdn"
      t.string "group", default: "Default"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
