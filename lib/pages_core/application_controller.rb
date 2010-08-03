module PagesCore
	class ApplicationController < ActionController::Base
		
		# Trap errors
		unless ActionController::Base.consider_all_requests_local
			rescue_from Exception,                            :with => :handle_exception
			rescue_from ActiveRecord::RecordNotFound,         :with => :handle_exception
			rescue_from ActionController::RoutingError,       :with => :handle_exception
			rescue_from ActionController::UnknownController,  :with => :handle_exception
			rescue_from ActionController::UnknownAction,      :with => :handle_exception
		end

		# Actions added to the SKIP_FILTERS array will be bypassed by filters. 
		# Useful for actions that don't rely on PagesCore.
		SKIP_FILTERS = [:render_dynamic_image]

		before_filter :domain_cache
		before_filter :authenticate,               :except => SKIP_FILTERS
		before_filter :load_account,               :except => SKIP_FILTERS
		before_filter :get_language,               :except => SKIP_FILTERS
		after_filter  :set_headers,                :except => SKIP_FILTERS
		after_filter  :set_authentication_cookies, :except => SKIP_FILTERS
		after_filter  :ensure_garbage_collection,  :except => SKIP_FILTERS
		
		before_filter :set_process_title
		after_filter  :unset_process_title
		
		if RAILS_ENV == "development"
			# Hooks for development mode
			def development_hooks
				# Mirror plugin assets on each request in development mode
				Rails.plugins.each do |plugin|
					Engines::Assets.mirror_files_for(plugin)
				end
			end
			before_filter :development_hooks
		end

		protected
		
			def domain_cache
				if PagesCore.config(:domain_based_cache)
					@@default_page_cache_directory ||= @@page_cache_directory
					@@page_cache_directory = File.join(@@default_page_cache_directory, request.domain)
				end
			end

			def set_process_title
				@@default_process_title ||= $0
				@@number_of_requests ||= 0
				@@number_of_requests += 1
				$0 = "#{@@default_process_title}: Handling #{request.path} (#{@@number_of_requests} reqs)"
			end
			
			def unset_process_title
				set_process_title
				$0 = "#{@@default_process_title}: Idle (#{@@number_of_requests} reqs)"
			end
			
			def handle_exception(exception)
				begin
					log_error exception
					if exception.kind_of?(ActionController::RoutingError)
						render_error 404
					else
						# Generate the error report
						error_report = {}
						error_report[:message]   = exception.to_s
						error_report[:url]       = "http://"+request.env['HTTP_HOST']
						error_report[:url]      += request.env['REQUEST_URI'] if request.env['REQUEST_URI']
						error_report[:params]    = params
						error_report[:env]       = request.env
						error_report[:session]   = session.instance_variable_get("@data")
						error_report[:backtrace] = clean_backtrace(exception)
						error_report[:timestamp] = Time.now
						if @current_user
							error_report[:user_id] = @current_user.id
						end

						sha1_hash = Digest::SHA1.hexdigest(error_report.to_yaml)

						error_report_dir  = File.join(RAILS_ROOT, 'log/error_reports')
						error_report_file = File.join(error_report_dir, "#{sha1_hash}.yml")
						`mkdir -p #{error_report_dir}` unless File.exists?(error_report_dir)

						unless File.exists?(error_report_file)
							File.open(error_report_file, 'w') do |fh|
								fh.write error_report.to_yaml
							end
						end

						session[:error_report] = sha1_hash
						@error_id = sha1_hash
						render_error 500
					end
				rescue
					render :template => 'errors/500_critical', :status => 500, :layout => false
				end
			end
		
			# Renders a fancy error page from app/views/errors. If the error name is numeric,
			# it will also be set as the response status. Example:
			#
			#   render_error 404
			#
			def render_error(error, options={})
				options[:status] ||= error if error.kind_of? Numeric
				options[:template] ||= "errors/#{error}"
				options[:layout] ||= 'errors'
				@email = (@current_user) ? @current_user.email : ""
				render options
			end
		
			# Redirect to the previous page, falling back to the options specified if that fails.
			# Example:
			#
			#   redirect_back_or_to "/"
			#
			def redirect_back_or_to(options={}, response_status={})
				begin
					redirect_to :back
				rescue #RedirectBackError
					redirect_to options, response_status
				end
			end

			# Loads the @account model, creating it if necessary.
			# This method is automatically run from a before_filter.
			def load_account
				if @account = Account.find_or_create
					PagesCore.config(:site_name, @account.name)
				end
			end
			
			# Sets MumboJumbo.current_language to the requested language, or
			# Language.default as a fallback.
			# This method is automatically run from a before_filter.
			def get_language
				@language = params[:language] || Language.default
				MumboJumbo.current_language = @language
			end
			
			# Sends HTTP headers (Content-Language etc) to the client.
			# This method is automatically run from an after_filter.
			def set_headers
				# Set the language header
				headers['Content-Language'] = Language.definition(@language.to_s).iso639_1 rescue nil if @language
			end

			# Performs garbage collection if the proper flags have been set.
			# This method is automatically run from an after_filter.
			def ensure_garbage_collection
				unless DynamicImage.clean_dirty_memory
					# clean_dirty_memory returns true if it performs garbage collection,
					# no need to do it twice.
				end
			end
		
			# === Authentication filter
			#
			# A user is considered authenticated if one of the following events occur (in this order):
			# * Valid username and password are passed through <tt>params[:login_username]</tt> and <tt>params[:login_password]</tt>
			# * <tt>session[:current_user_id]</tt> is set.
			# * <tt>cookies[:login_username]</tt> and <tt>cookies[:login_token]</tt> are set, and matches a valid UserLogin object.
			#
			# The user will not be authenticated if the account is deleted or not activated. An instance attribute - <tt>@current_user</tt> -
			# will be set if authentication is successfull, and can be used to test for a valid login in controllers and views.
			#
			# Conversely, any controller can log in a user for the duration of the session by setting <tt>@current_user</tt>, the 
			# mechanics are handled by <tt>set_authentication_cookies</tt>.
			#
			# This method is automatically run from a before_filter.
			def authenticate
				remote_ip = request.env['REMOTE_ADDR']

				if params[:logout]
					deauthenticate! :forcefully => true
				elsif params[:login_username] && params[:login_password]
					# Params auth
					if user = User.find_by_username( params[:login_username] )
						@current_user = user if @current_login = user.authenticate( :password => params[:login_password] )
					end
					login_attempted = true
				elsif session[:current_user_id]
					# Session auth - this should be pretty safe
					@current_user  = User.find( session[:current_user_id] )
					@current_login = UserLogin.find( session[:current_login_id] ) if session[:current_login_id] rescue nil
				elsif cookies[:login_username] && cookies[:login_token]
					# Cookie auth
					user = User.find_by_username( cookies[:login_username] )
					@current_user = user if user && @current_login = user.authenticate( :token => cookies[:login_token], :remote_ip => remote_ip )
				end

				if @current_user

					# Update the user record
					@current_user.update_attribute( :last_login_at, Time.now )

					# Create or update the login record
					if @current_login
						@current_login.user          ||= @current_user
						@current_login.remote_ip       = remote_ip
						@current_login.last_used_at    = Time.now
						@current_login.hashed_password = @current_user.hashed_password
						@current_login.save

					end

					set_authentication_cookies(:force => false)

					@current_user_is_admin = @current_user.is_admin?
				
					# Bounce through a redirect if the request isn't a get
					#if login_attempted && !request.get?
					#	redirect_request = request.request_parameters
					#	redirect_request.delete( 'login_password' )
					#	redirect_request.delete( 'login_username' )
					#	redirect_to redirect_request and return false
					#end
					
				else
					# Authentication failed, reset session and wipe cookies
					# TODO: only deauthenticate if a login was attempted
					deauthenticate!

					# Explicitely fail the login and redirect if login was attempted via params
					if login_attempted
						deauthenticate! :forcefully => true
						flash.now[:notice] = "The provided username/password combination was not valid"
					end
				end
				return true
			end


			# The session and cookie data is set in an after filter, since the data might have been changed by the controller.
			def set_authentication_cookies(options={})
				options[:force] = true unless options.has_key?(:force)
				# Set the cookies
				cookie_expiration = Time.now + 1.years
				if @current_user && (options[:force] || !cookies[:login_username] || cookies[:login_username] != @current_user.username)
					session[:current_user_id] = @current_user.id
					cookies[:login_username] = { :value => @current_user.username, :expires => cookie_expiration }
				end
				if @current_login && (options[:force] || !cookies[:login_token] || cookies[:login_token] != @current_login.token)
					session[:current_login_id] = @current_login.id
					cookies[:login_token]    = { :value => @current_login.token,   :expires => cookie_expiration }
				end
			end


			# Deauthenticate user; unset the instance variables, crumble cookies and optionally reset the session.
			# This is called from <tt>/users/logout</tt>, and <tt>authenticate</tt> if login fails.
			def deauthenticate!( options={} )
				cookies.delete :login_username
				cookies.delete :login_token
				@current_user  = nil
				@current_login = nil
				session[:current_user_id] = nil
				#reset_session if options[:forcefully]
			end

	end
end