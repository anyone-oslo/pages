# encoding: utf-8

class CreateMailouts < ActiveRecord::Migration
  def self.up
    create_table :mailouts do |t|
        t.string :subject, :sender, :template
        t.text   :body
            t.timestamps
    end
  end

  def self.down
    drop_table :mailouts
  end
end
