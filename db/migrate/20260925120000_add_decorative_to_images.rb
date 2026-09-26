# frozen_string_literal: true

class AddDecorativeToImages < ActiveRecord::Migration[8.1]
  def change
    add_column :images, :decorative, :boolean, default: false, null: false
  end
end
