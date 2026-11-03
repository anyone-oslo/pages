# frozen_string_literal: true

# Abstract controller for all frontend controllers.
module PagesCore
  class FrontendController < ::ApplicationController
    include PagesCore::DocumentTitleController
    include ApplicationHelper

    before_action :set_i18n_locale
    before_action :disable_static_cache_for_invalid_page_param
    helper_method :page_param

    # Loads @root_pages and @rss_feeds. To automatically load these in your
    # own controllers, add the following line to your controller definition:
    #
    #   before_action :load_root_pages
    #
    def load_root_pages
      @root_pages = Page.roots.localized(content_locale).published
      @rss_feeds = Page.where(feed_enabled: true)
                       .localized(content_locale)
                       .published
    end

    private

    def disable_static_cache_for_invalid_page_param
      return if params[:page].nil? || params[:page] == page_param.to_s

      disable_static_cache!
    end

    def page_param
      if params[:page].is_a?(String)
        (Integer(params[:page], exception: false) || 1).clamp(1, 10_000)
      else
        1
      end
    end

    def set_i18n_locale
      I18n.locale = content_locale
    rescue I18n::InvalidLocale
      raise if Rails.application.config.consider_all_requests_local

      render_error 404
    end
  end
end
