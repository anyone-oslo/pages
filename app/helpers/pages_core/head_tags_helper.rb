# frozen_string_literal: true

module PagesCore
  module HeadTagsHelper
    # Sets a document title.
    #
    #  document_title "Dashboard"
    #
    def document_title(*args)
      if args.any?
        @document_title = args.first
      else
        safe_join([@document_title, PagesCore.config(:site_name)].compact.uniq,
                  " - ")
      end
    end

    # Returns true if document title has been set.
    def document_title?
      @document_title ? true : false
    end

    # Generates links for all RSS feeds. Specify
    # :include_hidden to also include hidden pages.
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
      ] + feeds.map do |page|
        rss_link_tag("#{PagesCore.config(:site_name)}: #{page.name}",
                     page_url(content_locale, page, format: :rss))
      end
      safe_join(feed_tags, "\n")
    end

    # Outputs a HTML5 doctype and head tags, with document title
    # and relevant meta tags. Takes a block which will be placed
    # inside <head>.
    #
    #  <%= head_tag do %>
    #    <%= stylesheet_link_tag "application" %>
    #    <%= javascript_include_tag "application" %>
    #    <%= feed_tags %>
    #  <% end %>
    #
    def head_tag(&block)
      # The block output must be captured first
      block_output = block_given? ? capture(&block) : nil

      tag.head { safe_join(head_tag_contents(block_output), "\n") }
    end

    # Generates a link to an RSS feed.
    #
    #  rss_link_tag "My feed", "feed.rss"
    #
    def rss_link_tag(title, href)
      tag.link(rel: "alternate",
               type: "application/rss+xml",
               title: title,
               href: href)
    end

    private

    def head_tag_contents(block_output)
      [tag.meta(charset: "utf-8"),
       tag.meta("http-equiv" => "X-UA-Compatible", "content" => "IE=edge"),
       tag.title(document_title),
       meta_description_tag,
       meta_keywords_tag,
       (tag.link(rel: "image_src", href: meta_image) if meta_image?),
       open_graph_tags,
       csrf_meta_tags,
       block_output]
    end

    def meta_description_tag
      return unless meta_description?

      tag.meta(name: "description", content: meta_description)
    end

    def meta_keywords_tag
      return unless meta_keywords?

      tag.meta(name: "keywords", content: meta_keywords)
    end
  end
end
