# frozen_string_literal: true

class RemoveImagesets < ActiveRecord::Migration[4.2]
  def self.up
    drop_table :imagesets
    drop_table :images_imagesets
  end

  def self.down
    create_table "images_imagesets" do |t|
      t.integer "relation_id"
      t.integer "imageset_id"
      t.integer "image_id"
      t.integer "position"
    end

    create_table "imagesets" do |t|
      t.string "name"
      t.text "description"
      t.datetime "created_at"
      t.integer "user_id"
    end
  end
end
