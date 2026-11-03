# frozen_string_literal: true

module PagesCore
  module Authentication
    extend ActiveSupport::Concern

    class LoginRefused < StandardError; end

    included do
      before_action :start_authenticated_session
      after_action :finalize_authenticated_session
      helper_method :current_user, :logged_in?
      rescue_from LoginRefused, with: :login_refused
    end

    # Returns the current user if logged in, or nil.
    attr_reader :current_user

    # Returns true if the user is logged in.
    def logged_in?
      current_user ? true : false
    end

    def authenticate!(user)
      reset_session
      raise LoginRefused unless user.can_login?

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

    def login_refused
      flash[:notice] = t("pages_core.invalid_login")
      redirect_to admin_login_url
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
      return unless user&.can_login? &&
                    user.session_token == user_session[:token]

      authenticated(user)
    end
  end
end
