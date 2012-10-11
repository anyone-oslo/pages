# encoding: utf-8

class DropPartials < ActiveRecord::Migration
  def self.up
    drop_table :partials
  end

  def self.down
    create_table :partials do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
