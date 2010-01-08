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


# ActionMailer monkey patch
if RAILS_GEM_VERSION == '2.2.2' || RAILS_GEM_VERSION == '2.2.3'
	module ActionMailer
		class Base
			def perform_delivery_smtp(mail)
				destinations = mail.destinations
				mail.ready_to_send
				sender = mail['return-path'] || mail.from
				smtp = Net::SMTP.new(smtp_settings[:address], smtp_settings[:port])
				smtp.enable_starttls_auto if smtp_settings[:enable_starttls_auto] && smtp.respond_to?(:enable_starttls_auto)
				smtp.start(smtp_settings[:domain], smtp_settings[:user_name], smtp_settings[:password],
				smtp_settings[:authentication]) do |smtp|
					smtp.sendmail(mail.encoded, sender, destinations)
				end
			end
		end
	end
end