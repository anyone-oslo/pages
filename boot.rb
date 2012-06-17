# encoding: utf-8

if RAILS_ENV == 'production'
	require 'activerecord'
	require 'actionmailer'
	ActionMailer::Base.delivery_method = :sendmail
	ActionMailer::Base.sendmail_settings = {
		:location       => '/usr/sbin/sendmail',
		:arguments      => '-i -t -f no-reply@manualdesign.no'
	}
end