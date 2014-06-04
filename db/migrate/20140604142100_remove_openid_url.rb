class RemoveOpenidUrl < ActiveRecord::Migration
  def self.up
    remove_column :users, :openid_url
  end

  def self.down
    add_column :users, :openid_url, :string
  end
end
