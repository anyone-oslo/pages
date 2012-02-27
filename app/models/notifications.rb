# encoding: utf-8

class Notifications < ActionMailer::Base

	helper ActionView::Helpers::UrlHelper

	def generic_mailer( options )
		@recipients = options[:recipients] || ""
		@from       = options[:from]       || ""
		@cc         = options[:cc]         || ""
		@bcc        = options[:bcc]        || ""
		@subject    = options[:subject]    || ""
		@body       = options[:body]       || {}
		@headers    = options[:headers]    || {}
		@charset    = options[:charset]    || "utf-8"
	end

	# Create placeholders for whichever e-mails you need to deal with.
	# Override mail elements where necessary
	#
	# def contact_us( options )
	#	 self.generic_mailer( options )
	# end

	def newsletter( sender, recipients, subject, message, ctype )
		@from       = sender
		@subject    = subject
		@body       = { :message => message }
		@recipients = recipients
		@sent_on    = Time.now
		@headers    = {}
		content_type ctype
	end

end
