# frozen_string_literal: true

module PagesCore
  module ErrorReporting
    extend ActiveSupport::Concern

    included do
      before_action :configure_sentry_scope
    end

    protected

    def configure_sentry_scope
      return if Rails.env.test? || !Object.const_defined?("Sentry")

      Sentry.set_context("params", params.to_unsafe_h)
      Sentry.set_tags(locale: params[:locale] || I18n.default_locale.to_s)
      Sentry.set_user(current_user_context)
    end

    def current_user_context
      return {} unless logged_in?

      { id: current_user.id,
        email: current_user.email }
    end
  end
end
