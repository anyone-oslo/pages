module PagesCore
	def self.config(key, value=nil)
		key = key.to_s
		@@config ||= {}
		@@config[key] = value if value != nil
		@@config[key]
	end
	
	def self.configure(options={})
		options.each do |key,value|
			self.config(key, value)
		end
	end
	
	config :localizations,          false
	config :text_filter,            'textile'
	config :page_image_is_linkable, false
	config :page_additional_images, false
	config :page_additional_files,  false
    config :newsletter_template,    false
	config :newsletter_image,       false
	config :page_cache,             false
	
	config :sphinx_enabled,         false # Enables Sphinx search engine
	
	#config :comment_notifications,  [:author, 'your@email.com']
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

	# Monkey patch for fixing file upload breakage
	class CgiResponse  
		def out_with_espipe(*args)  
			begin  
				out_without_espipe(*args)  
			rescue Errno::ESPIPE => exception  
				File.open(File.join(File.dirname(__FILE__), '../../../../log/cgiresponse.log'), 'a'){|fh| fh.write(exception.to_s)} rescue nil
				begin  
					message    = exception.to_s + "\r\n" + exception.backtrace.join("\r\n")
					RAILS_DEFAULT_LOGGER.fatal(message)  
				rescue Exception => e
					$stderr.write("Exception #{e.to_s} in handling exception #{exception.to_s}")  
				end  
			end  
		end  
		alias_method_chain :out, :espipe  
	end
end
	
require "pages_core/acts_as_textable"
require "pages_core/methoded_hash"
require "pages_core/cache_sweeper"
require "pages_core/application_controller"
require "pages_core/string_translator"
require "pages_core/string_extensions"
require "pages_core/array_extensions"
require "pages_core/awstats"
require "pages_core/paginates"
