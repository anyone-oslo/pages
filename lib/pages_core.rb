module PagesCore
	def self.config( key, value=nil )
		key = key.to_s
		@@config ||= {}
		@@config[key] = value if value != nil
		@@config[key]
	end
	
	config :localizations,          false
	config :text_filter,            'textile'
	config :page_image_is_linkable, false
	config :page_additional_images, false
	config :page_additional_files,  false
    config :newsletter_template,    false
	config :newsletter_image,       false
	config :page_cache,             false
end

module ActionController

	class ActionControllerError < StandardError #:nodoc:
	end
	class RoutingError < ActionControllerError #:nodoc:
		attr_reader :failures
		def initialize(message, failures=[])
			super(message)
			@failures = failures
		end
	end

	class Base #:nodoc:
		def rescue_action_in_public( exception )
			log_error( exception )
			if( exception.class == RoutingError )
				render_error 404
			else
				error_report = {}
				error_report[:message]   = exception.to_s
				error_report[:url]       = "http://"+request.env['HTTP_HOST']
				error_report[:url]      += request.env['REQUEST_URI'] if request.env['REQUEST_URI']
				error_report[:params]    = params
				error_report[:env]       = request.env
				error_report[:session]   = session.instance_variable_get( "@data" )
				error_report[:backtrace] = clean_backtrace( exception )
				error_report[:timestamp] = Time.now
				session[:error_report]   = error_report
				render_error 500
			end
		end
	end
end
	

%w{acts_as_textable application_controller string_translator awstats}.each{|l| require "pages_core/#{l}"}

