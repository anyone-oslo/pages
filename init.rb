require 'pages_core'
PagesCore.init!

# Why the hell is this here?
class Image < ActiveRecord::Base
	has_many :album_images
	has_many :albums, :through => :album_images
end

# reCAPTCHA config
Recaptcha.configure do |config|
	config.public_key  = '***REMOVED***'
	config.private_key = '***REMOVED***'
end

# Initialize and configure Haml/Sass
require 'sass'
require 'sass/plugin' if defined?(Sass)
Sass::Plugin.options[:template_location] = File.join(RAILS_ROOT, 'app/assets/stylesheets')