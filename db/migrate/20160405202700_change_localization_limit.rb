# frozen_string_literal: true

class ChangeLocalizationLimit < ActiveRecord::Migration[4.2]
  def up
    change_column :localizations, :value, :text, limit: 16_777_215
  end

  def down
    change_column :localizations, :value, :text, limit: 65_535
  end
end
