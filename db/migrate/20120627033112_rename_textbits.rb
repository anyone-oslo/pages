# frozen_string_literal: true

class RenameTextbits < ActiveRecord::Migration[4.2]
  def self.up
    rename_table :textbits, :localizations
    rename_column :localizations, :language, :locale
    rename_column :localizations, :textable_id, :localizable_id
    rename_column :localizations, :textable_type, :localizable_type
    rename_column :localizations, :body, :value
  end

  def self.down
    rename_table :localizations, :textbits
    rename_column :textbits, :locale, :language
    rename_column :textbits, :localizable_id, :textable_id
    rename_column :textbits, :localizable_type, :textable_type
    rename_column :textbits, :value, :body
  end
end
