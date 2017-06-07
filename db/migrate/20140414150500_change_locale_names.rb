# encoding: utf-8

class ChangeLocaleNames < ActiveRecord::Migration[4.2]
  def self.up
    Localization.where(locale: "nor").update_all(locale: "nb")
    Localization.where(locale: "eng").update_all(locale: "en")
  end

  def self.down
    Localization.where(locale: "en").update_all(locale: "eng")
    Localization.where(locale: "nb").update_all(locale: "nor")
  end
end
