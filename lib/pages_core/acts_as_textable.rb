# encoding: utf-8

module PagesCore
	module ActsAsTextable

		class << self
			def textable_fields
				@@textable_fields  ||= {}
			end

			def textable_options
				@@textable_options ||= {}
			end
		end

		# Model for <tt>acts_as_textable</tt>
		module Model
			# Class methods for <tt>acts_as_textable</tt> models
			module ClassMethods
				def languages(options={})
					options = {:type => self.to_s}.merge(options)
					Textbit.languages(options)
				end
				def fields( options={} )
					options = {:type => self.to_s}.merge(options)
					Textbit.fields( options )
				end
				def textable_options
					PagesCore::ActsAsTextable.textable_options[self] || {}
				end
			end

			def root_class
				rc = self.class
				while rc.superclass != ActiveRecord::Base
					rc = rc.superclass
				end
				rc
			end

			# Set the working language
			def working_language=(language)
				@working_language = language.to_s
			end

			# Get the working language
			def working_language
				@working_language ||= Language.default
			end

			# Set the fallback language
			def fallback_language=(language)
				@fallback_language = language.to_s
			end

			# Get the fallback language
			def fallback_language
				@fallback_language || self.root_class.textable_options[:fallback_language]
			end

			# Does this model have a fallback language?
			def fallback_language?
				self.fallback_language ? true : false
			end

			def attributes=(new_attributes, guard_protected_attributes=true)
				attributes = new_attributes.dup
				attributes.stringify_keys!
				attributes = remove_attributes_protected_from_mass_assignment(attributes) if guard_protected_attributes
				attributes.each do |attribute, value|
					if self.has_field?(attribute)
						attributes.delete(attribute)
						set_textbit_body(attribute, value)
					end
				end
				super(attributes, guard_protected_attributes)
			end

			# Returns true if this page has the named textbit
			def has_field?(name, options={})
				return true if (PagesCore::ActsAsTextable.textable_fields[self.root_class].include?(name))
				(self.fields.include?(name.to_s)) ? true : false
			end

			# Get the textbit with specified name (and optional language), create and add it if necessary
			def get_textbit(name, options={})
				name = name.to_s

				languages      = options[:language] ? [options[:language]] : [self.working_language, self.fallback_language].compact
				named_textbits = self.textbits.select{|tb| tb.name == name}
				textbit        = nil

				# Find the first applicable textbit
				languages.each do |lang|
					if !textbit && named_textbits.select{|tb| tb.language == lang.to_s}.length > 0
						textbit = named_textbits.select{|tb| tb.language == lang.to_s}.first
					end
				end

				# Default to a blank one
				textbit ||= Textbit.new(:name => name, :textable => self, :language => languages.first)
				self.textbits.push(textbit) if textbit.new_record?

				textbit
			end

			# Set the body of a named textbit (usually, through method_missing)
			def set_textbit_body( name, value, options={} )
				if value.kind_of? Hash
					value.each do |language,string|
						set_textbit_body( name, string, options.merge( { :language => language } ) )
					end
				else
					options = {:language => self.working_language}.merge(options)
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

			def field_has_language?(name, language=nil)
				languages = (language ? language : [self.working_language, self.fallback_language].compact)
				languages = [languages] unless languages.kind_of?(Array)
				languages = languages.map{|l| l.to_s}

				available_languages = self.languages_for_field(name)
				languages.each{|l| return true if available_languages.include?(l)}
				return false
			end

			# Returns an array with the names of all text blocks excluding special fields.
			def fields
				self.textbits.collect{|tb| tb.name }.uniq.compact.reject{|name| PagesCore::ActsAsTextable.textable_fields[self.root_class].include?(name)}
			end

			# Returns an array with the names of all text blocks.
			def all_fields
				self.textbits.collect {|tb| tb.name }.uniq.compact
			end

			# Returns an array with the names of all text blocks with the given
			# language code.
			def fields_for_languague(language)
				self.textbits.collect {|tb| tb.name if tb.language == language.to_s }.uniq.compact.reject {|name| PagesCore::ActsAsTextable.textable_fields[ self.root_class ].include? name }
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
				fields = fields.concat( PagesCore::ActsAsTextable.textable_fields[ self.root_class ] ) if fields.empty?
				fields.each do |name|
					tb = get_textbit( name, { :language => language } )
				end
				languages
			end

			# Get a translated version of this record
			def translate(language, options={})
				dupe = self.dup.translate!(language, options)
				(block_given?) ? (yield dupe) : dupe
			end

			# Translate this record
			def translate!(language, options={})
				language = language.to_s
				self.working_language = language
				self.fallback_language = options[:fallback_language] if options[:fallback_language]
				self
			end

			# Enable virtual setters and getters for existing (and enforced) textbits
			def method_missing( method_name, *args )
				name,type = method_name.to_s.match( /(.*?)([\?=]?)$/ )[1..2]
				if has_field? name
					case type
					when "?"
						field_has_language?(name)
					when "="
						set_textbit_body(name, args.first)
					else
						get_textbit(name)
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
		def self.acts_as_textable(*args)
			options = args.last.kind_of?(Hash) ? args.pop : {}
			options.symbolize_keys!
			fields = args.flatten
			include PagesCore::ActsAsTextable::Model
			self.class.send(:include, PagesCore::ActsAsTextable::Model::ClassMethods)
			has_many :textbits, :as => :textable, :dependent => :destroy, :order => "name"
			after_save :save_textbits
			PagesCore::ActsAsTextable.textable_fields[self]  = fields.map{|f| f.to_s}
			PagesCore::ActsAsTextable.textable_options[self] = options
			before_validation do |textable|
				invalid_textbits = textable.textbits.select{ |tb| !tb.valid? }
				unless invalid_textbits.empty?
					textable.textbits.delete( invalid_textbits )
				end
			end
		end
	end
end