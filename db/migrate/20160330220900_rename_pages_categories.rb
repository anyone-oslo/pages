class RenamePagesCategories < ActiveRecord::Migration[4.2]
  def change
    rename_table :pages_categories, :page_categories
    add_column :page_categories, :id, :primary_key, first: true
  end
end
