# frozen_string_literal: true

class AddSkipIndexToPages < ActiveRecord::Migration[7.2]
  def change
    add_column :pages, :skip_index, :boolean, null: false, default: false
  end
end
