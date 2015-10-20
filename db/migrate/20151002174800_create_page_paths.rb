class CreatePagePaths < ActiveRecord::Migration
  def change
    create_table :page_paths do |t|
      t.belongs_to :page
      t.string :locale, :path
      t.timestamps null: false
    end
    add_index :page_paths, [:locale, :path], unique: true
  end
end
