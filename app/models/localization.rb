# encoding: utf-8

# Patch older versions of RedCloth to fix Textile hard breaking
if Object.const_defined?("RedCloth") && RedCloth.kind_of?(Class)
  class RedCloth < String
    def hard_break( text )
      lines = text.split( /[\n]{2,}/m ).collect do |line|
        line.gsub!( /\n/, "<br />\n" ) unless ( line.match( /^[\s]*(\*|#|\|)[\s]/ ) || line.match( /\|[\s]*$/ ) )
        line
      end.join( "\n\n" ) if hard_breaks
      text.replace lines
      end
  end
end

class Localization < ActiveRecord::Base
  belongs_to :localizable, :polymorphic => true

  #validates_presence_of :value

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


  def to_s #( options={} )
    text = self.value || ""
  end

  def to_html_with( text, options={} )
    text = " " + text
    string = self.to_s
    if options.has_key?( :shorten ) && string.length > options[:shorten]
      string = string[0..options[:shorten]] + "..."
    end

    case self.filter
    when "textile"
      converter = RedCloth.new( string + text )
      converter.hard_breaks = true
      converter.to_html.html_safe
    when "markdown"
      converter = BlueCloth.new( string + text)
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
      converter = RedCloth.new( string )
      converter.hard_breaks = true
      converter.to_html.html_safe
    when "markdown"
      converter = BlueCloth.new( string )
      converter.to_html.html_safe
    else
      string.html_safe
    end
  end

  def empty?
    ( self.to_s.empty? ) ? true : false
  end

  def translate(locale)
    localization = self.class.find( :first, :conditions => [ "localizable_id = ? AND localizable_type = ? AND name = ? AND locale = ?", self.localizable_id, self.localizable_type, self.name, locale ] )
    #if localization == nil
    #	localization = self.class.new( { :localizable_id => self.localizable_id, :localizable_type => self.localizable_type, :name => self.name, :locale => locale } )
    #end
    localization
  end

end
