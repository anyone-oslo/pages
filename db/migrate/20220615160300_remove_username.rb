# frozen_string_literal: true

class RemoveUsername < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :username, :string
  end
end
