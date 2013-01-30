# encoding: utf-8

class CreatePageFiles < ActiveRecord::Migration
  def self.up
    create_table :page_files do |t|
      t.column :page_id,      :integer
      t.column :position,     :integer
      t.column :name,         :string
      t.column :filename,     :string
      t.column :content_type, :string
      t.column :filesize,     :integer  # 2gb limit be damned
      t.column :binary_id,    :integer
      t.column :created_at,   :datetime
      t.column :updated_at,   :datetime
    end
  end

  def self.down
    drop_table :page_files
  end
end
