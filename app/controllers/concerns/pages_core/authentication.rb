# encoding: utf-8

module PagesCore
  module Authentication
    extend ActiveSupport::Concern

    included do
      before_action :start_authenticated_session
      after_action  :finalize_authenticated_session
      helper_method :current_user, :logged_in?
    end

    # Returns the current user if logged in, or nil.
    def current_user
      @current_user
    end

    # Returns true if the user is logged in.
    def logged_in?
      current_user ? true : false
    end

    def authenticate!(user)
      if !user.last_login_at || user.last_login_at < 10.minutes.ago
        user.update(last_login_at: Time.now)
      end
      @current_user = user
    end

    def deauthenticate!
      @current_user  = nil
      session[:current_user_id] = nil
      session[:authenticated_openid_url] = nil
    end

    protected

    def start_authenticated_session
      if session[:current_user_id]
        user = User.where(id: session[:current_user_id]).first

      elsif !session[:authenticated_openid_url].blank?
        user = User.authenticate_by_openid_url(session[:authenticated_openid_url])
      end

      if user && user.can_login?
        authenticate!(user)
      end
    end

    def finalize_authenticated_session
      if current_user
        session[:current_user_id] = current_user.id
      end
    end
  end
end