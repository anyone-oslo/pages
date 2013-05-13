# encoding: utf-8

class Localization < ActiveRecord::Base
  belongs_to :localizable, polymorphic: true

  class << self

    def locales
      self.select('DISTINCT locale').map(&:locale)
    end

    def names
      self.select('DISTINCT name').map(&:name)
    end

  end

  def to_s
    self.value || ""
  end

  def empty?
    self.to_s.empty?
  end

  def translate(locale)
    localizable.localizations.where(name: self.name, locale: locale).first
  end

end
