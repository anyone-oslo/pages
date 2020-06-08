# frozen_string_literal: true

class UpdateDelayedJobTable < ActiveRecord::Migration[4.2]
  def up
    change_column :delayed_jobs, :last_error, :text
  end

  def down
    change_column :delayed_jobs, :last_error, :string
  end
end
