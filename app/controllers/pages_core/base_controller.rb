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

    after_action :set_content_language_header

    protected

    def append_info_to_payload(payload)
      super
      payload[:remote_ip] = request.remote_ip
      payload.merge!(current_user_context)
    end

    def set_content_language_header
      return unless locale

      headers["Content-Language"] = locale.to_s
    end
  end
end
