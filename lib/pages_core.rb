
# Load ./pages_core/*.rb
Dir.entries(File.join(File.dirname(__FILE__), 'pages_core')).select{|f| f =~ /\.rb$/}.map{|f| File.basename(f, '.*')}.each do |lib|
	unless lib =~ /^bootstrap/
		require File.join(File.dirname(__FILE__), 'pages_core', lib)
	end
end

module PagesCore
	class << self
		def init!
			# Verify that we've been properly bootstrapped
			unless PagesCore.const_defined?('BOOTSTRAPPED') && PagesCore::BOOTSTRAPPED
				puts "---------------------------------------------------------------------------------------------------------------"
				puts "PAGES BOOTSTRAPPER NOT LOADED!"
				puts "Please run \"rake pages:update\" to patch config/environment.rb, or add the following line yourself:"
				puts "\n# Bootstrap Pages"
				puts "require File.join(File.dirname(__FILE__), '../vendor/plugins/pages/boot')"
				puts "---------------------------------------------------------------------------------------------------------------"
				raise "Pages not bootstrapped"
			end
			
			# Load dependencies
			PagesCore::Dependencies.load

			# Initialize MumboJumbo
			MumboJumbo.load_languages!
			MumboJumbo.translators << PagesCore::StringTranslator

			# Register default mime types
			Mime::Type.register "application/rss+xml", 'rss'
			
			# Register with PagesConsole
			PagesCore.register_with_pages_console
		end

		def application_name
			dir = RAILS_ROOT
			dir.gsub(/\/current\/?$/, '').gsub(/\/releases\/[\d]+\/?$/, '').split('/').last
		end
		
		def register_with_pages_console
			begin
				require 'pages_console'
				site = PagesConsole::Site.new(self.application_name, RAILS_ROOT)
				PagesConsole.ping(site)
			rescue MissingSourceFile
				# Nothing to do, PagesConsole not installed.
			end
		end

		def configure(options={}, &block)
			if block_given?
				if options[:reset] == :defaults
					load_default_configuration
				elsif options[:reset] === true
					@@configuration = PagesCore::Configuration::SiteConfiguration.new
				end
				yield self.configuration if block_given?
			else
				# Legacy
				options.each do |key,value|
					self.config(key, value)
				end
			end
		end
		
		def load_default_configuration
			@@configuration = PagesCore::Configuration::SiteConfiguration.new
			
			config.localizations       :disabled
			config.page_cache          :enabled
			config.newsletter.template :disabled
			config.newsletter.image    :disabled
			config.text_filter         :textile
			
			#config.comment_notifications [:author, 'your@email.com']
		end
		
		def configuration(key=nil, value=nil)
			load_default_configuration unless self.class_variables.include?('@@configuration')
			if key
				configuration.send(key, value) if value != nil
				configuration.get(key)
			else
				@@configuration
			end
		end
		alias :config :configuration
	end
	
	#config :localizations,          false
	#config :text_filter,            'textile'
	#config :page_image_is_linkable, false
	#config :page_additional_images, false
	#config :page_additional_files,  false
    #config :newsletter_template,    false
	#config :newsletter_image,       false
	#config :page_cache,             false
	
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