#module PagesCore; BOOTSTRAPPED = true; end
require File.join(File.dirname(__FILE__), 'lib/pages_core/bootstrap')
PagesCore.bootstrap!

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

if RAILS_ENV == 'production'
	ActionMailer::Base.delivery_method = :sendmail
	ActionMailer::Base.sendmail_settings = {
		:location       => '/usr/sbin/sendmail',
		:arguments      => '-i -t -f support@manualdesign.no'
	}
end