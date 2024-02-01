# frozen_string_literal: true

class RemovePersistentData < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :persistent_data, :text
  end
end
