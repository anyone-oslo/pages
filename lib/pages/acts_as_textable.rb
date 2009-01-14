module Pages
	module ActsAsTextable
	
		class << self
			# Return the config hash, create it if necessary
			def textable_fields
				@@textable_fields        ||= Hash.new
			end
		end

		# Model for <tt>acts_as_textable</tt>
		module Model
			
			# Class methods for <tt>acts_as_textable</tt> models
			module ClassMethods
				def languages( options={} )
					options = { :type => self.to_s }.merge( options )
					Textbit.languages( options )
				end
				def fields( options={} )
					options = { :type => self.to_s }.merge( options )
					Textbit.fields( options )
				end
			end
			
			def working_language=( language )
				@working_language = language.to_s
			end
			def working_language
				@working_language ||= Language.default
			end

			# Returns true if this page has the named textbit
			def has_field?( name, options={} )
				return true if( Pages::ActsAsTextable.textable_fields[ self.class ].include? name )
				( self.fields.include? name.to_s ) ? true : false
			end


			# Get the textbit with specified name (and optional language), create and add it if necessary
			def get_textbit( name, options={} )
				name = name.to_s
				options[:language] ||= ( @working_language || Language.default )
				self.textbits.each do |tb|
					if( tb.name == name && tb.language == options[:language].to_s )
						return tb
					end
				end

				# Create new textbit if necessary
				textbit ||= Textbit.new( :name => name, :textable => self, :language => options[:language].to_s )
				if textbit.new_record?
					self.textbits.push textbit
				end
				textbit
			end

			# Set the body of a named textbit (usually, through method_missing)
			def set_textbit_body( name, value, options={} )
				if value.kind_of? Hash
					value.each do |language,string|
						set_textbit_body( name, string, options.merge( { :language => language } ) )
					end
				else
					textbit = get_textbit( name, options )
					textbit.body = value
				end
			end


			# Save all related textbits
			def save_textbits
				self.textbits.each do |tb|
					tb.save
				end
			end

			# Returns an array of all language codes present on this page.
			def languages
				self.textbits.collect {|tb| tb.language }.uniq.compact
			end

			# Returns an array of language codes this field is translated into.
			def languages_for_field( name )
				self.textbits.collect {|tb| tb.language if tb.name == name }.uniq.compact
			end
			
			def field_has_language?( name, language=nil )
				language ||= @working_language
				language = language.to_s
				( self.languages_for_field( name ).include?( language.to_s ) ) ? true : false
			end

			# Returns an array with the names of all text blocks excluding special fields.
			def fields
				self.textbits.collect {|tb| tb.name }.uniq.compact.reject {|name| Pages::ActsAsTextable.textable_fields[ self.class ].include? name }
			end

			# Returns an array with the names of all text blocks.
			def all_fields
				self.textbits.collect {|tb| tb.name }.uniq.compact
			end

			# Returns an array with the names of all text blocks with the given 
			# language code.
			def fields_for_languague( language )
				self.textbits.collect {|tb| tb.name if tb.language == language.to_s }.uniq.compact.reject {|name| Pages::ActsAsTextable.textable_fields[ self.class ].include? name }
			end


			# Delete all text blocks with the given language code(s).
			# This operation is destructive, hence the name.
			def destroy_language( language )
				language = language.to_s
				textbits = self.textbits.collect {|tb| tb if tb.language == language }.compact
				textbits.each {|tb| self.textbits.delete( tb ); tb.destroy }
			end


			# Delete all text blocks with the given name(s).
			# This operation is destructive, hence the name.
			def destroy_field( name )
				if name.kind_of? String
					textbits = self.textbits.collect {|tb| tb if tb.name == name }.compact
					textbits.each {|tb| self.textbits.delete( tb ); tb.destroy }
				elsif name.kind_of? Enumerable
					name.each {|n| destroy_field( n ) }
				end
			end


			# Add a field
			def add_field( name )
				languages = self.languages
				languages << Language.default if languages.empty?
				languages.each do |lang|
					tb = get_textbit( name, { :language => lang } )
				end
				fields
			end


			# Add a language
			def add_language( language )
				language = language.to_s
				fields = self.all_fields
				fields = fields.concat( Pages::ActsAsTextable.textable_fields[ self.class ] ) if fields.empty?
				fields.each do |name|
					tb = get_textbit( name, { :language => language } )
				end
				languages
			end
		
			# Get a translated version of this page
			def translate( language )
				language = language.to_s
				#self.add_language( language )
				dupe = self.dup
				dupe.working_language = language
				( block_given? ) ? ( yield dupe ) : dupe
			end

			# Enable virtual setters and getters for existing (and enforced) textbits
			def method_missing( method_name, *args )
				name,type = method_name.to_s.match( /(.*?)([\?=]?)$/ )[1..2]
				if has_field? name
					case type
						when "?"
							field_has_language? name
						when "="
							set_textbit_body( name, args.first )
						else
							get_textbit( name )
					end
				else
					super
				end
			end

		end
	end
end

# ActsAsTextable adds <tt>acts_as_textable</tt> to ActionController::Base
module ActiveRecord
	class Base
		# Controller is textable. This adds the methods from <tt>ActsAsTextable::Model</tt>.
		def self.acts_as_textable( fields=[], options={} )
			unless fields.kind_of? Enumerable
				fields = [fields]
			end
			include Pages::ActsAsTextable::Model
			self.class.send( :include, Pages::ActsAsTextable::Model::ClassMethods )
			has_many :textbits, :as => :textable, :dependent => :destroy, :order => "name"
			after_save :save_textbits
			Pages::ActsAsTextable.textable_fields[ self ] = fields.map{ |f| f.to_s }
			before_validation do |textable|
				invalid_textbits = textable.textbits.select{ |tb| !tb.valid? }
				unless invalid_textbits.empty?
					textable.textbits.delete( invalid_textbits )
				end
			end
		end
	end
end