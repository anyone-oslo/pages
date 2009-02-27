# Configuration file for Pages CMS
# Be sure to restart your web server when you modify this file.

require 'acts_as_ferret'

# Default language
Language.default = Language.code_for_name("<%= @default_language %>")

# reCAPTCHA API keys
# ENV['RECAPTCHA_PUBLIC_KEY']  = ''
# ENV['RECAPTCHA_PRIVATE_KEY'] = ''

# Flickr API key
#ENV['FLICKR_API_KEY']        = ''

module PagesCore
	config :site_name,              '<%= @site_name %>'                         # Name of site
	config :default_sender,         '<%= @mail_sender %>'                       # Default email sender
	config :localizations,          false                                       # Set to true to enable multiple languages
	config :text_filter,            'textile'                                   # Default text filter (markdown is available)
	config :page_additional_images, true                                        # Enable image uploading on pages
	config :page_files,             false                                       # Enable file uploading on pages
	config :page_image_is_linkable, false                                       # Page image is linkable
	config :recaptcha,              true                                        # Enable reCAPTCHA
	config :flickr_api,             false                                       # Enable Flickr API integration
	config :http_caching,           true
	config :page_cache,             true                                        # Enable page caching
	
	# Configure the cache sweeper, add any custom paths and models
	# CacheSweeper.config do |sweeper_config|
	# 	sweeper_config.observe  += [Store, StoreTest, Ad]
	# 	sweeper_config.patterns += [/^\/arkiv(.*)$/, /^\/tests(.*)$/]
	# end
end

module Newsletter
    # Additional subscribers for newsletter
	def self.subscriber_groups
		[
			#{ :name => "Group name", :class => "Model", :method => :email, :conditions => nil }
		]
	end
end