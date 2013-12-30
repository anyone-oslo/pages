# encoding: utf-8

module PagesCore
  module Authentication
    extend ActiveSupport::Concern

    included do
      before_action :authenticate
      after_action  :set_authentication_cookies
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

    protected

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
    # This method is automatically run from a before_action.
    def authenticate
      remote_ip = request.env['REMOTE_ADDR']

      if params[:logout]
        deauthenticate! :forcefully => true

      # Login with username and password
      elsif params[:login_username] && params[:login_password]
        if user = User.where(username: params[:login_username].to_s).first
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
          @current_user.update(last_login_at: Time.now)
        end
        set_authentication_cookies(:force => false)

        @current_user_is_admin = @current_user.is_admin?

        # Bounce through a redirect if the request isn't a get
        #if login_attempted && !request.get?
        # redirect_request = request.request_parameters
        # redirect_request.delete( 'login_password' )
        # redirect_request.delete( 'login_username' )
        # redirect_to redirect_request and return false
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
  end
end