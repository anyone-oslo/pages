# encoding: utf-8

require 'digest/sha1'
require 'iconv'
require 'find'
require 'open-uri'
require 'pathname'

# -----

require "rails"
require 'active_record'
require 'action_controller'
require 'action_view'
require 'action_mailer'

#require "rake"
#require "mysql"
#require "rdoc"

require "bcrypt"
require 'vector2d'
require 'enumerable_mapper'
require 'simple-rss'
require 'RedCloth'
require 'daemon-spawn'
require 'pages_console'
require 'openid'
require 'httparty'
require 'delayed_job'

require 'dynamic_image'

require 'sass'
require 'json'
require 'coffee-script'

require 'acts_as_list'
require 'acts_as_tree'

require "recaptcha/rails"

require 'thinking-sphinx'
require 'thinking_sphinx/deltas/delayed_delta'

# -----

# Included in lib/
[:acts_as_taggable, :language, :country_select].each do |lib|
	require File.join(File.dirname(__FILE__), lib.to_s)
end

# Load ./pages_core/*.rb
require File.join(File.dirname(__FILE__), 'pages_core', 'plugin')
Dir.entries(File.join(File.dirname(__FILE__), 'pages_core')).select{|f| f =~ /\.rb$/}.map{|f| File.basename(f, '.*')}.each do |lib|
	unless lib =~ /^bootstrap/
		require File.join(File.dirname(__FILE__), 'pages_core', lib)
	end
end

module PagesCore
	class << self
		def init!
			# Register default mime types
			Mime::Type.register "application/rss+xml", 'rss'

			# Register with PagesConsole
			PagesCore.register_with_pages_console
		end

		def version
			VERSION
		end

		def plugin_root
			Pathname.new(File.dirname(__FILE__)).join('..').expand_path
		end

		def application_name
			dir = Rails.root.to_s
			dir.gsub(/\/current\/?$/, '').gsub(/\/releases\/[\d]+\/?$/, '').split('/').last
		end

		def register_with_pages_console
			begin
				require 'pages_console'
				site = PagesConsole::Site.new(self.application_name, Rails.root.to_s)
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
