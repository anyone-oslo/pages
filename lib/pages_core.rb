# encoding: utf-8

require 'digest/sha1'
require 'iconv'
require 'find'
require 'open-uri'
require 'pathname'

# Included in vendor/plugins/pages/lib
[:acts_as_taggable, :language, :mumbojumbo, :feed_builder, :country_select].each do |lib|
	require File.join(File.dirname(__FILE__), lib.to_s)
end

# Load ./pages_core/*.rb
Dir.entries(File.join(File.dirname(__FILE__), 'pages_core')).select{|f| f =~ /\.rb$/}.map{|f| File.basename(f, '.*')}.each do |lib|
	unless lib =~ /^bootstrap/
		require File.join(File.dirname(__FILE__), 'pages_core', lib)
	end
end

module PagesCore
	class << self
		def init!
			# Initialize MumboJumbo
			MumboJumbo.load_languages!
			MumboJumbo.translators << PagesCore::StringTranslator

			# Register default mime types
			Mime::Type.register "application/rss+xml", 'rss'

			# Register with PagesConsole
			PagesCore.register_with_pages_console
		end

		def version
			@@version ||= File.read(plugin_root.join('VERSION'))
		end

		def plugin_root
			Pathname.new(File.dirname(__FILE__)).join('..').expand_path
		end

		def application_name
			dir = RAILS_ROOT
			dir.gsub(/\/current\/?$/, '').gsub(/\/releases\/[\d]+\/?$/, '').split('/').last
		end

		def register_with_pages_console
			begin
				require 'pages_console'
				site = PagesConsole::Site.new(self.application_name, RAILS_ROOT)
				PagesConsole.ping(site)
			rescue MissingSourceFile
				# Nothing to do, PagesConsole not installed.
			end
		end

		def configure(options={}, &block)
			if block_given?
				if options[:reset] == :defaults
					load_default_configuration
				elsif options[:reset] === true
					@@configuration = PagesCore::Configuration::SiteConfiguration.new
				end
				yield self.configuration if block_given?
			else
				# Legacy
				options.each do |key,value|
					self.config(key, value)
				end
			end
		end

		def load_default_configuration
			@@configuration = PagesCore::Configuration::SiteConfiguration.new

			config.localizations       :disabled
			config.page_cache          :enabled
			config.newsletter.template :disabled
			config.newsletter.image    :disabled
			config.text_filter         :textile

			#config.comment_notifications [:author, 'your@email.com']
		end

		def configuration(key=nil, value=nil)
			load_default_configuration unless self.class_variables.include?('@@configuration')
			if key
				configuration.send(key, value) if value != nil
				configuration.get(key)
			else
				@@configuration
			end
		end
		alias :config :configuration
	end

end