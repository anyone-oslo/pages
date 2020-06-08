# frozen_string_literal: true

class AddMetaImageToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :meta_image_id, :integer
  end
end
