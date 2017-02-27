# encoding: utf-8

# Abstract controller for all frontend controllers.
module PagesCore
  class FrontendController < ::ApplicationController
    include ApplicationHelper

    before_action :set_i18n_locale

    # Loads @root_pages and @rss_feeds. To automatically load these in your
    # own controllers, add the following line to your controller definition:
    #
    #   before_action :load_root_pages
    #
    def load_root_pages
      @root_pages = Page.roots.localized(@locale).published
      @rss_feeds = Page.where(feed_enabled: true).localized(@locale).published
    end

    private

    def legacy_locales
      {
        "nor" => "nb",
        "eng" => "en"
      }
    end

    def set_i18n_locale
      locale_param = params[:locale] || I18n.default_locale
      if legacy_locales[locale_param]
        locale_param = legacy_locales[locale_param]
      end
      I18n.locale = locale_param
    rescue I18n::InvalidLocale
      raise if Rails.application.config.consider_all_requests_local
      render_error 404
    end
  end
end
