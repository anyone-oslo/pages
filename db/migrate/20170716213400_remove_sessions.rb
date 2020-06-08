# frozen_string_literal: true

class RemoveSessions < ActiveRecord::Migration[5.0]
  def up
    drop_table :sessions
  end

  def down
    create_table :sessions do |t|
      t.string :session_id
      t.text :data
      t.datetime :updated_at
      t.index :session_id
      t.index :updated_at
    end
  end
end
