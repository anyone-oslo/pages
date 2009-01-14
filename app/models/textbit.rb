require 'bluecloth'
require 'redcloth'
require 'language'

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

class Textbit < ActiveRecord::Base
	belongs_to :textable, :polymorphic => true

	validates_presence_of :body
	
	validate do |textbit|
		if !textbit[:filter] || textbit[:filter].blank?
			textbit.filter = Backstage.config( :text_filter ).to_s
		end
	end
	
	class << self
		def fetch_simple_array_from_sql( field, options={} )
			sql = ActiveRecord::Base.connection();
			options.symbolize_keys!
			query = "SELECT DISTINCT `#{field}` FROM `#{self.table_name}`"
			conditions = []
			conditions << "textable_type = '#{options[:type]}'"     if options.has_key? :type
			conditions << "textable_id   = #{options[:id]}"         if options.has_key? :id
			conditions << "name          = '#{options[:name]}'"     if options.has_key? :name
			conditions << "filter        = '#{options[:filter]}'"   if options.has_key? :filter
			conditions << "language      = '#{options[:language]}'" if options.has_key? :language
			query += " WHERE "+conditions.join( ' AND ' ) if conditions.length > 0
			rows = []
			result = sql.execute( query );
			while row = result.fetch_row
				rows << row
			end
			rows.flatten.sort
		end
		
		def languages( options={} )
			self.fetch_simple_array_from_sql( 'language', options )
		end
		
		def fields( options={} )
			self.fetch_simple_array_from_sql( 'name', options )
		end
	end
	
	def filter
		( self[:filter] && !self[:filter].blank? ) ? self[:filter] : Backstage.config( :text_filter ).to_s
	end
	
	
	def to_s #( options={} )
		text = self.body || ""
	end
	
	def to_html_with( text, options={} )
		text = " " + text
		string = self.to_s
		if options.has_key?( :shorten ) && string.length > options[:shorten]
			string = string[0..options[:shorten]] + ".."
		end
		
		case self.filter
		when "textile"
			converter = RedCloth.new( string + text )
			converter.hard_breaks = true
			converter.to_html
		when "markdown"
			converter = BlueCloth.new( string + text)
			converter.to_html
		else
			string + text
		end
	end
	
	def to_html( options={} )
		string = self.to_s
		if options.has_key?( :shorten ) && string.length > options[:shorten]
			string = string[0..options[:shorten]] + ".."
		end

		case self.filter
		when "textile"
			converter = RedCloth.new( string )
			converter.hard_breaks = true
			converter.to_html
		when "markdown"
			converter = BlueCloth.new( string )
			converter.to_html
		else
			string
		end
	end

	def empty?
		( self.to_s.empty? ) ? true : false
	end
	
	def translate( language )
		textbit = Textbit.find( :first, :conditions => [ "textable_id = ? AND textable_type = ? AND name = ? AND language = ?", self.textable_id, self.textable_type, self.name, language ] )
		#if textbit == nil
		#	textbit = Textbit.new( { :textable_id => self.textable_id, :textable_type => self.textable_type, :name => self.name, :language => language } )
		#end
		textbit
	end
	
end
