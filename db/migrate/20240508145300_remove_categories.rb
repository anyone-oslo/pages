# frozen_string_literal: true

class RemoveCategories < ActiveRecord::Migration[7.0]
  def change
    drop_table :page_categories do |t|
      t.integer :page_id
      t.integer :category_id
      t.index :category_id
      t.index :page_id
    end

    drop_table :categories do |t|
      t.string :name
      t.string :slug
      t.integer :position
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index :slug
    end
  end
end
