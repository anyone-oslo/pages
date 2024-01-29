# frozen_string_literal: true

module PagesCore
  module Authentication
    extend ActiveSupport::Concern

    included do
      before_action :start_authenticated_session
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
      session[:current_user] = { id: user.id, token: user.session_token }
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
      user_session = session.fetch(:current_user, nil)&.symbolize_keys

      return unless user_session

      user = User.find_by(id: user_session[:id])
      return unless user && user.session_token == user_session[:token]

      authenticated(user)
    end
  end
end
