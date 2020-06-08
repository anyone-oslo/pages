# frozen_string_literal: true

class RemovePageComments < ActiveRecord::Migration[5.0]
  def up
    drop_table :page_comments
    remove_column :pages, :comments_allowed
    remove_column :pages, :comments_count
  end

  def down
    add_column :pages, :comments_allowed, :boolean, default: true, null: false
    add_column :pages, :comments_count, :integer,
               limit: 4, default: 0, null: false
    create_table :page_comments do |t|
      t.integer :page_id
      t.string :remote_ip
      t.string :name
      t.string :email
      t.string :url
      t.text :body
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
