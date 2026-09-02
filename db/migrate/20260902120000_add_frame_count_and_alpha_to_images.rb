# frozen_string_literal: true

class AddFrameCountAndAlphaToImages < ActiveRecord::Migration[8.1]
  def change
    add_column :images, :frame_count, :integer
    add_column :images, :alpha, :boolean
    add_index :images, :content_hash
  end
end
