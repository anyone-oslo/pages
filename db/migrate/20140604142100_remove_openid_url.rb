# frozen_string_literal: true

class RemoveOpenidUrl < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :users, :openid_url
  end

  def self.down
    add_column :users, :openid_url, :string
  end
end
