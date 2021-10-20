# frozen_string_literal: true

module PagesCore
  module Authentication
    extend ActiveSupport::Concern

    included do
      before_action :start_authenticated_session
      after_action :finalize_authenticated_session
      helper_method :current_user, :logged_in?
    end

    # Returns the current user if logged in, or nil.
    attr_reader :current_user

    # Returns true if the user is logged in.
    def logged_in?
      current_user ? true : false
    end

    def authenticate!(user)
      reset_session
      authenticated(user)
    end

    def deauthenticate!
      @current_user = nil
      reset_session
    end

    protected

    def authenticated(user)
      user.mark_active!
      @current_user = user
    end

    def start_authenticated_session
      if session[:current_user_id]
        user = User.where(id: session[:current_user_id]).first
      end

      return unless user&.can_login?

      authenticated(user)
    end

    def finalize_authenticated_session
      return unless current_user

      session[:current_user_id] = current_user.id
    end
  end
end
