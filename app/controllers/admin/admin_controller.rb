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

    def set_i18n_locale
      I18n.locale = :en
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

    def secure_compare(compare, other)
      return false unless compare && other
      return false unless compare.bytesize == other.bytesize

      l = compare.unpack "C#{compare.bytesize}"

      res = 0
      other.each_byte { |byte| res |= byte ^ l.shift }
      res.zero?
    end
  end
end
