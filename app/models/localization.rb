# encoding: utf-8

class Localization < ActiveRecord::Base
  belongs_to :localizable, polymorphic: true

  class << self
    def locales
      order("locale ASC").pluck("DISTINCT locale")
    end

    def names
      order("name ASC").pluck("DISTINCT name")
    end
  end

  def to_s
    value || ""
  end

  def empty?
    to_s.empty?
  end

  def translate(locale)
    localizable.localizations.where(name: name, locale: locale).first
  end
end
