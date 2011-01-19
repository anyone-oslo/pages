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

# Monkey patch CGI::Session::CookieStore to default session expiry 
# to 3 years into the future.
class CGI::Session::CookieStore
	alias_method :original_write_cookie, :write_cookie
    def write_cookie(options)
		options['expires'] ||= 3.years.from_now
		original_write_cookie(options)
	end
end