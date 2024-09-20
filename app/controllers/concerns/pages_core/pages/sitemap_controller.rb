# frozen_string_literal: true

module PagesCore
  module Pages
    module SitemapController
      extend ActiveSupport::Concern

      def sitemap
        respond_to do |format|
          format.xml { render xml: pages_sitemap.to_xml }
        end
      end

      private

      def pages_sitemap
        pages = Page.published.where.not(skip_index: true).localized(locale)

        PagesCore::Sitemap.new do |map|
          pages.each { |p| map.add(page_url(locale, p), lastmod: p.updated_at) }
        end
      end
    end
  end
end
