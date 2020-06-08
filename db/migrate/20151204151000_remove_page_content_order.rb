# frozen_string_literal: true

class RemovePageContentOrder < ActiveRecord::Migration[4.2]
  def change
    remove_column :pages, :content_order, :string
  end
end
