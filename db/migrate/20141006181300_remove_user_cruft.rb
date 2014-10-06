class RemoveUserCruft < ActiveRecord::Migration
  def change
    remove_column :users, :token, :string
    remove_column :users, :is_deleted, :boolean, default: false, null: false
    remove_column :users, :born_on, :date
    remove_column :users, :mobile, :string
    remove_column :users, :web_link, :string
    rename_column :users, :is_activated, :activated
    rename_column :users, :realname, :name
  end
end
