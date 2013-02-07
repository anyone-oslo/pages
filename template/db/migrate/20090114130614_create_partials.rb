# encoding: utf-8

class CreatePartials < ActiveRecord::Migration
  def self.up
    remove_column :page_fragments, :name
    remove_column :page_fragments, :description
    remove_column :page_fragments, :author_id
    rename_column :page_fragments, :slug, :name
    rename_table  :page_fragments, :partials
  end

  def self.down
    rename_table :partials, :page_fragments
    rename_column :page_fragments, :name, :slug
    add_column :page_fragments, :name, :string
    add_column :page_fragments, :author_id, :integer
    add_column :page_fragments, :description, :text
  end
end
