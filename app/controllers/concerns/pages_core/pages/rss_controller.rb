# frozen_string_literal: true

module PagesCore
  module Pages
    module RssController
      extend ActiveSupport::Concern

      private

      def all_feed_items
        feeds = Page.enabled_feeds(locale, include_hidden: true)
        Page.where(parent_page_id: feeds)
            .order("published_at DESC")
            .published
            .localized(locale)
      end

      def per_page_rss_param(default = 20, max = 1000)
        return default unless params[:per_page].is_a?(String)

        params[:per_page].to_i.clamp(1, max)
      end

      def render_page_rss(page, pagination_page = 1)
        if page.feed_enabled?
          render_rss(page.pages.paginate(per_page: per_page_rss_param,
                                         page: pagination_page)
                         .includes(:image, :author),
                     title: page.name)
        else
          render_error 404
        end
      end

      def render_rss(items, title: nil)
        @title = PagesCore.config.site_name
        @title += ": #{title}" if title
        @items = items
        @summary = params[:summary].present?
        render template: "feeds/pages", layout: false
      end
    end
  end
end
