# frozen_string_literal: true

module PagesCore
  module FeedTagsHelper
    # Generates links for all RSS feeds. Specify :include_hidden
    # to link the combined feed when only hidden feeds exist.
    #
    #  feed_tags
    #  feed_tags include_hidden: true
    #
    def feed_tags(options = {})
      feeds = Page.enabled_feeds(content_locale, options)
      return unless feeds.any?

      feed_tags = [
        rss_link_tag(PagesCore.config(:site_name),
                     pages_url(content_locale, format: :rss))
      ] + feeds.select(&:published?).map do |page|
        rss_link_tag("#{PagesCore.config(:site_name)}: #{page.name}",
                     page_url(content_locale, page, format: :rss))
      end
      safe_join(feed_tags, "\n")
    end

    private

    def rss_link_tag(title, href)
      tag.link(rel: "alternate", type: "application/rss+xml", title:, href:)
    end
  end
end
