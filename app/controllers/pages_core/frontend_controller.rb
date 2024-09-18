# frozen_string_literal: true

# Abstract controller for all frontend controllers.
module PagesCore
  class FrontendController < ::ApplicationController
    include ApplicationHelper

    before_action :set_i18n_locale
    helper_method :document_title, :page_param

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

    def document_title(*args)
      @document_title = args.first if args.any?
      @document_title
    end

    def page_param
      if params[:page].is_a?(String)
        [Integer(params[:page], exception: false), 1].compact.max
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
