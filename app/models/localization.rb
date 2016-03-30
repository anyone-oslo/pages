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

  delegate :empty?, to: :to_s

  def translate(locale)
    localizable.localizations.find_by(name: name, locale: locale)
  end
end
