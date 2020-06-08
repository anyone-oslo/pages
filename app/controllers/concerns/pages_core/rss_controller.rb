# frozen_string_literal: true

module PagesCore
  module RssController
    extend ActiveSupport::Concern

    private

    def all_feed_items
      feeds = Page.enabled_feeds(locale, include_hidden: true)
      Page.where(parent_page_id: feeds)
          .order("published_at DESC")
          .published
          .limit(20)
          .localized(locale)
    end

    def render_rss(items, title: nil)
      @title = PagesCore.config.site_name
      @title += ": #{title}" if title
      @items = items
      render template: "feeds/pages", layout: false
    end
  end
end
