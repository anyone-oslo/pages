# encoding: utf-8

class CreatePageComments < ActiveRecord::Migration
  def self.up
    create_table :page_comments do |t|
      t.column :page_id, :integer
      t.column :remote_ip, :string
      t.column :name, :string
      t.column :email, :string
      t.column :url, :string
      t.column :body, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_column :pages, :comments_allowed, :boolean, :null => false, :default => '1'
  end

  def self.down
    drop_table :page_comments
    remove_column :pages, :comments_allowed
  end
end
