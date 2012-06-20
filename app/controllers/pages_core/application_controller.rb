# encoding: utf-8

class PagesCore::ApplicationController < ActionController::Base

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
	after_filter  :compile_assets,             :except => SKIP_FILTERS
	after_filter  :set_headers,                :except => SKIP_FILTERS
	after_filter  :set_authentication_cookies, :except => SKIP_FILTERS
	after_filter  :ensure_garbage_collection,  :except => SKIP_FILTERS

	before_filter :set_process_title
	after_filter  :unset_process_title

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
					error_report[:env]       = request.env.inject({}) do |hash, value|
						if value.first.kind_of?(String) && value.last.kind_of?(String)
							hash[value.first] = value.last
						end
						hash
					end
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

		# Compiles assets
		def compile_assets
			PagesCore::Assets.compile!
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
		# * <tt>session[:authenticated_openid_url]</tt> is set.
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

			# Login with username and password
			elsif params[:login_username] && params[:login_password]
				if user = User.find_by_username(params[:login_username])
					if user.authenticate(:password => params[:login_password])
						user.rehash_password!(params[:login_password]) if user.password_needs_rehash?
						@current_user = user
					end
				end
				login_attempted = true

			# Login with session
			elsif session[:current_user_id]
				@current_user = User.find(session[:current_user_id]) rescue nil
				login_attempted = true

			# Login with OpenID
			elsif !session[:authenticated_openid_url].blank?
				if user = User.authenticate_by_openid_url(session[:authenticated_openid_url])
					@current_user = user
				end
				#login_attempted = true

			end

			if @current_user

				# Update the user record
				if !@current_user.last_login_at || @current_user.last_login_at < 10.minutes.ago
					@current_user.update_attribute(:last_login_at, Time.now)
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
			if @current_user
				session[:current_user_id] = @current_user.id
			end
		end


		# Deauthenticate user; unset the instance variables, crumble cookies and optionally reset the session.
		# This is called from <tt>/users/logout</tt>, and <tt>authenticate</tt> if login fails.
		def deauthenticate!( options={} )
			@current_user  = nil
			session[:current_user_id] = nil
			session[:authenticated_openid_url] = nil if options[:forcefully]
			#reset_session if options[:forcefully]
		end

		# Returns an OpenID consumer, creating it if necessary.
		def openid_consumer
			require 'openid/store/filesystem'
			@openid_consumer ||= OpenID::Consumer.new(session,
				OpenID::Store::Filesystem.new("#{RAILS_ROOT}/tmp/openid"))
		end

		# Start an OpenID session
		def start_openid_session(identity_url, options={})
			options[:success] ||= root_path
			options[:fail]    ||= root_path
			session[:openid_redirect_success] = options[:success]
			session[:openid_redirect_fail]    = options[:fail]

			response = openid_consumer.begin(identity_url) rescue nil
			if response #&& response.status == OpenID::SUCCESS
				perform_openid_authentication(response, options)
				return true
			else
				return false
			end
		end

		# Perform OpenID authentication
		def perform_openid_authentication(response, options={})
			options = {
				:url       => complete_openid_url,
				:base_url  => root_url,
				:immediate => false
			}.merge(options)
			redirect_to response.redirect_url(options[:base_url], options[:url], options[:immediate])
		end


end