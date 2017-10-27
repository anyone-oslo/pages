class RemoveFilterFromLocalizations < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :localizations, :filter
  end

  def self.down
    add_column :localizations, :filter, :string
  end
end
