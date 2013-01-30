# encoding: utf-8

require 'rubygems'
require 'builder'
require 'iconv'
require 'active_support'

module FeedBuilder

  class FeedNotValidError < Exception; end

  def self.format_value( value )
    if value.kind_of?( Date )
      value = value.to_time
    end
    if value.kind_of?( Time )
      value = value.to_formatted_s( :rfc822 )
    end
    value
  end

  class ItemCollection < Array
    attr_accessor :feed
    def <<( item )
      unless item.kind_of? Item
        item = Item.new( item )
      end
      item.feed = self.feed
      super item
    end
    def valid?
      self.each do |item|
        return false unless item.valid?
      end
      return true
    end
  end

  module AttributeMachine
    def set_attributes( attributes={} )
      attributes.each do |key,value|
        key = key.to_sym
        if all_attributes.include?( key )
          @attributes[key] = value
        end
      end
    end

    def method_missing( name, *args )
      if name.to_s.match( /^(.*)=$/ ) && all_attributes.include?( $1.to_sym )
        @attributes[$1.to_sym] = args.first
      elsif all_attributes.include?( name )
        @attributes[name] || nil
      else
        super
      end
    end

    def valid?
      required_attributes.each do |a|
        return false unless @attributes.has_key?( a )
      end
      return true
    end
  end

  class Feed
    include AttributeMachine
    attr_reader   :attributes, :items
    attr_accessor :encoding

    # Required RSS 2.0
    REQUIRED_ATTRIBUTES = :title, :link, :description

    # Optional RSS 2.0
    OPTIONAL_ATTRIBUTES = [
      :language,        # en-us
      :copyright,       # Copyright 2002, Spartanburg Herald-Journal
      :managing_editor, # geo@herald.com (George Matesky)
      :web_master,      # betty@herald.com (Betty Guernsey)
      :pub_date,        # RFC 822 date
      :last_build_date, # RFC 822 date
      :categories,      # Array of categories
      :generator,       # MightyInHouse Content System v2.3
      :docs,            # http://cyber.law.harvard.edu/rss/rss.html
      :ttl,             # Time to live in minutes
      :cloud,           # <cloud domain="rpc.sys.com" port="80" path="/RPC2" registerProcedure="pingMe" protocol="soap"/>
      :image,           # GIF/PNG/JPG
      :rating,          # PICS rating - http://www.w3.org/PICS/
      :skip_hours,
      :skip_days
    ]

    ALL_ATTRIBUTES = REQUIRED_ATTRIBUTES + OPTIONAL_ATTRIBUTES

    def required_attributes; REQUIRED_ATTRIBUTES; end
    def optional_attributes; OPTIONAL_ATTRIBUTES; end
    def all_attributes;      ALL_ATTRIBUTES; end

    def initialize( attributes={} )
      @encoding = ( attributes[:encoding] ||= "UTF-8" )
      @attributes = Hash.new
      set_attributes attributes
      attributes[:items] ||= []
      self.items = attributes[:items]
    end

    def items=( collection )
      @items = ItemCollection.new
      @items.feed = self
      collection.each do |item|
        @items << item
      end
    end

    def to_rss
      raise FeedNotValidError unless self.valid?
      converter = Iconv.new( @encoding + "//TRANSLIT", 'utf-8' )
      xml = Builder::XmlMarkup.new( :indent => 2 )
      xml << "<?xml version=\"1.0\" encoding=\"" + @encoding.upcase + "\"?>\n"
      xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
        xml.channel do
          all_attributes.select{ |a| @attributes.has_key?( a ) }.each do |a|
            value = converter.iconv( FeedBuilder.format_value( @attributes[a] ) )
            unless value =~ /[<>]/
              xml.tag! a.to_s.camelcase( :lower ), converter.iconv( value )
            else
              xml.tag!( a.to_s.camelcase( :lower ) ){ xml.cdata!( converter.iconv( value ) ) }
            end
          end
          @items.each do |item|
            item.to_rss( xml )
          end
        end
      end
    end

    def valid?
      ( self.items.valid? && super ) ? true : false
    end

  end

  class Item
    attr_accessor :feed
    include AttributeMachine
    REQUIRED_ATTRIBUTES = []

    # Optional RSS 2.0 - either title or description must be present
    OPTIONAL_ATTRIBUTES = [
      :title,
      :link,
      :description,
      :author,          # oprah\@oxygen.net
      :categories,      # array of categories
      :comments,        # URL of a page for comments
      :enclosure,       # describes a media object that is attached to the item
      :guid,            # a string that uniquely identifies the item (url)
      :pub_date,        # RFC 822
      :source           # The RSS channel that the item came from
    ]

    ALL_ATTRIBUTES = REQUIRED_ATTRIBUTES + OPTIONAL_ATTRIBUTES

    def required_attributes; REQUIRED_ATTRIBUTES; end
    def optional_attributes; OPTIONAL_ATTRIBUTES; end
    def all_attributes;      ALL_ATTRIBUTES; end

    def initialize( attributes={} )
      @attributes = Hash.new
      set_attributes attributes
    end

    def valid?
      ( ( @attributes[:title] || @attributes[:description] ) && super ) ? true : false
    end

    def to_rss( xml=nil )
      xml ||= Builder::XmlMarkup.new( :indent => 2 )
      converter = Iconv.new( @feed.encoding + "//TRANSLIT", 'utf-8' )
      xml.item do
        all_attributes.select{ |a| @attributes.has_key?( a ) }.each do |a|
          if a == :enclosure
            xml.enclosure :url => @attributes[a][:url], :type => @attributes[a][:type]
          else
            value = converter.iconv( FeedBuilder.format_value( @attributes[a] ) )
            value = value.gsub("“", "&#8221;").gsub("”", "&#8221;") rescue value
            value = value.gsub("'", "&#8217;") rescue value
            unless value =~ /[<>]/
              xml.tag! a.to_s.camelcase( :lower ), converter.iconv( value )
            else
              xml.tag!( a.to_s.camelcase( :lower ) ){ xml.cdata!( converter.iconv( value ) ) }
            end
          end
        end
      end
    end
  end

end
