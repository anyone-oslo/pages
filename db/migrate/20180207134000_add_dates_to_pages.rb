class AddDatesToPages < ActiveRecord::Migration[5.0]
  def change
    change_table :pages do |t|
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :all_day, null: false, default: false
      t.index :starts_at
      t.index :ends_at
    end
  end
end
