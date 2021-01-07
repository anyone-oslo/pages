# frozen_string_literal: true

module PagesCore
  module ErrorReporting
    extend ActiveSupport::Concern

    included do
      before_action :configure_sentry_context
    end

    protected

    def configure_sentry_context
      if Object.const_defined?("Sentry")
        Sentry.set_user(current_user_context)
        Sentry.set_tags(locale: params[:locale] || I18n.default_locale.to_s)
        Sentry.set_extras(params: params.to_unsafe_h)
      elsif Object.const_defined?("Raven")
        configure_legacy_sentry_context
      end
    end

    def configure_legacy_sentry_context
      Raven.user_context(current_user_context)
      Raven.tags_context(locale: params[:locale] || I18n.default_locale.to_s)
      Raven.extra_context(params: params.to_unsafe_h)
    end

    def current_user_context
      return { user_id: :guest } unless logged_in?

      { user_id: current_user.id,
        user_email: current_user.email }
    end
  end
end
