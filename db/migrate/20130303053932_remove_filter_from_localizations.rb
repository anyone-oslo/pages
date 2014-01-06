# encoding: utf-8

class RemoveFilterFromLocalizations < ActiveRecord::Migration
  def self.up
    remove_column :localizations, :filter
  end

  def self.down
    add_column :localizations, :filter, :string
  end
end
