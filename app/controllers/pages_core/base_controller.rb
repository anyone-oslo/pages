# encoding: utf-8

module PagesCore
  class BaseController < ActionController::Base
    include PagesCore::Authentication
    include PagesCore::DomainBasedCache
    include PagesCore::ErrorRenderer
    include PagesCore::ProcessTitler
    include PagesCore::PoliciesHelper

    before_action :set_locale, :configure_error_reporting
    after_action :set_content_language_header

    protected

    # Configures additional report data if Sentry is installed
    def configure_error_reporting
      return unless Object.const_defined?("Raven")
      if logged_in?
        Raven.user_context(user_id: current_user.id,
                           user_email: current_user.email)
      else
        Raven.user_context({})
      end
      Raven.tags_context(locale: locale)
      Raven.extra_context(params: params.to_unsafe_h)
    end

    # Sets @locale from params[:locale], with I18n.default_locale as fallback
    def set_locale
      legacy_locales = {
        "nor" => "nb",
        "eng" => "en"
      }
      @locale = params[:locale] || I18n.default_locale.to_s
      @locale = legacy_locales[@locale] if legacy_locales[@locale]
    end

    def set_content_language_header
      return unless locale
      headers["Content-Language"] = locale.to_s
    end
  end
end
