# encoding: utf-8

class Localization < ActiveRecord::Base
  belongs_to :localizable, :polymorphic => true

  validate do |localization|
    if !localization[:filter] || localization[:filter].blank?
      localization.filter = PagesCore.config( :text_filter ).to_s
    end
  end

  class << self

    def locales
      self.select('locale').uniq.map{ |l| l.locale }
    end

    def names
      self.select('name').uniq.map{ |l| l.name }
    end

  end

  def filter
    ( self[:filter] && !self[:filter].blank? ) ? self[:filter] : PagesCore.config( :text_filter ).to_s
  end


  def to_s
    self.value || ""
  end

  def to_html_with( text, options={} )
    text = " " + text
    string = self.to_s
    if options.has_key?( :shorten ) && string.length > options[:shorten]
      string = string[0..options[:shorten]] + "..."
    end

    case self.filter
    when "textile"
      converter = RedCloth.new(string + text)
      converter.to_html.html_safe
    when "markdown"
      converter = BlueCloth.new(string + text)
      converter.to_html.html_safe
    else
      (string + text).html_safe
    end
  end

  def to_html( options={} )
    string = self.to_s
    if options.has_key?( :shorten ) && string.length > options[:shorten]
      string = string[0..options[:shorten]] + "..."
    end

    case self.filter
    when "textile"
      converter = RedCloth.new(string)
      converter.to_html.html_safe
    when "markdown"
      converter = BlueCloth.new( string )
      converter.to_html.html_safe
    else
      string.html_safe
    end
  end

  def empty?
    self.to_s.empty?
  end

  def translate(locale)
    localizable.localizations.where(:name => self.name, :locale => locale).first
  end

end
