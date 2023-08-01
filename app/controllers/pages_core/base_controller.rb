# frozen_string_literal: true

module PagesCore
  class BaseController < ActionController::Base
    include PagesCore::Authentication
    include PagesCore::ErrorRenderer
    include PagesCore::ErrorReporting
    include PagesCore::LocalesHelper
    include PagesCore::ProcessTitler
    include PagesCore::PoliciesHelper
    include PagesCore::StaticCacheController

    before_action :set_locale
    after_action :set_content_language_header

    protected

    def append_info_to_payload(payload)
      super
      payload[:remote_ip] = request.remote_ip
      payload.merge!(current_user_context)
    end

    # Sets @locale from params[:locale], with I18n.default_locale as fallback
    def set_locale
      @locale = content_locale
    end

    def set_content_language_header
      return unless locale

      headers["Content-Language"] = locale.to_s
    end
  end
end
