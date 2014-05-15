class RemoveSphinxDeltas < ActiveRecord::Migration
  def self.up
    remove_index :users, name: :delta_index
    remove_index :pages, name: :delta_index
    remove_column :pages, :delta
    remove_column :users, :delta
  end

  def self.down
    add_index "users", ["delta"], name: "delta_index"
    add_index "pages", ["delta"], name: "delta_index"
    add_column :users, :delta, :boolean, null: false, default: false
    add_column :pages, :delta, :boolean, null: false, default: false
  end
end
