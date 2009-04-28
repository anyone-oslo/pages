# Configuration file for Pages CMS
# Be sure to restart your web server when you modify this file.

# Default language
Language.default = Language.code_for_name("<%= @default_language %>")

# reCAPTCHA API keys
# ENV['RECAPTCHA_PUBLIC_KEY']  = ''
# ENV['RECAPTCHA_PRIVATE_KEY'] = ''

# Flickr API key
#ENV['FLICKR_API_KEY']        = ''

PagesCore.configure(
	:site_name              => '<%= @site_name %>',                         # Name of site
	:default_sender         => '<%= @mail_sender %>',                       # Default email sender
	:localizations          => false,                                       # Set to true to enable multiple languages
	:text_filter            => 'textile',                                   # Default text filter (markdown is available)
	:page_additional_images => true,                                        # Enable image uploading on pages
	:page_files             => false,                                       # Enable file uploading on pages
	:page_image_is_linkable => false,                                       # Page image is linkable
	:recaptcha              => false,                                       # Enable reCAPTCHA
	:flickr_api             => false,                                       # Enable Flickr API integration
	:http_caching           => true,
	:page_cache             => true,                                        # Enable page caching
	:sphinx_enabled         => true
)	

# Configure the cache sweeper, add any custom paths and models
# PagesCore::CacheSweeper.config do |sweeper_config|
# 	sweeper_config.observe  += [Store, StoreTest, Ad]
# 	sweeper_config.patterns += [/^\/arkiv(.*)$/, /^\/tests(.*)$/]
# end

module Newsletter
    # Additional subscribers for newsletter
	def self.subscriber_groups
		[
			#{ :name => "Group name", :class => "Model", :method => :email, :conditions => nil }
		]
	end
end