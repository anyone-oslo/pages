# frozen_string_literal: true

module Admin
  class AdminController < ::ApplicationController
    protect_from_forgery with: :exception

    before_action :set_i18n_locale
    before_action :require_authentication

    layout "admin"

    helper_method :search_query

    class << self
      # Get name of class with in lowercase, with underscores.
      def underscore
        ActiveSupport::Inflector.underscore(to_s).split("/").last
      end
    end

    def redirect
      if Page.news_pages.any?
        redirect_to news_admin_pages_url(content_locale)
      else
        redirect_to admin_pages_url(content_locale)
      end
    end

    protected

    def search_query
      params[:q] || ""
    end

    def trusted_url_options
      if Rails.application.config.hosts.any?
        { host: request.host,
          port: request.optional_port,
          protocol: request.protocol }
      else
        mailer_url_options
      end
    end

    def mailer_url_options
      options = AdminMailer.default_url_options.symbolize_keys
      if options[:host].blank?
        raise "Can't build links in emails: set config.hosts or " \
              "config.action_mailer.default_url_options"
      end

      { port: nil, protocol: "https" }.merge(options.slice(:host, :port, :protocol))
    end

    def set_i18n_locale
      I18n.locale = :en
    end

    def normalized_email
      email = params[:email]
      email.strip.downcase if email.is_a?(String)
    end

    def rate_limited
      flash[:notice] = t("pages_core.rate_limited")
      redirect_to admin_login_url
    end

    # Verifies the login. Redirects to users/new if the users table is empty.
    # If not, renders the login screen.
    def require_authentication
      return if logged_in?

      if User.count < 1
        redirect_to(new_admin_user_url)
      else
        redirect_to(admin_login_url)
      end
    end
  end
end
