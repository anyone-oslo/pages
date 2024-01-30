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

    def finalize_authenticated_session
      return unless logged_in?

      session[:current_user] =
        { id: current_user.id, token: current_user.session_token }
    end

    def start_authenticated_session
      user_session = session.fetch(:current_user, nil)&.symbolize_keys

      return unless user_session

      user = User.find_by(id: user_session[:id])
      return unless user && user.session_token == user_session[:token]

      authenticated(user)
    end
  end
end
