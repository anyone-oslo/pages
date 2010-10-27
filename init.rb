# Dependencies are configured in lib/pages_core/dependencies.rb and loaded by PagesCore.init!

require 'pages_core'
PagesCore.init!

# Why the hell is this here? 
class Image < ActiveRecord::Base
	has_many :album_images
	has_many :albums, :through => :album_images
end

# reCaptcha Global Keys
ENV['RECAPTCHA_PUBLIC_KEY']  = "***REMOVED***"
ENV['RECAPTCHA_PRIVATE_KEY'] = "***REMOVED***"