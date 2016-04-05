class ChangeLocalizationLimit < ActiveRecord::Migration
  def up
    change_column :localizations, :value, :text, limit: 16_777_215
  end

  def down
    change_column :localizations, :value, :text, limit: 65_535
  end
end
