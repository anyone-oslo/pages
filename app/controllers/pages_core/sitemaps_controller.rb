# frozen_string_literal: true

module PagesCore
  class SitemapsController < ApplicationController
    include PagesCore::PagePathHelper
    static_cache :index, :pages

    def index
      @sitemaps = PagesCore::Sitemap.sitemaps.flat_map do |entry|
        if entry.is_a?(Proc)
          locales.map { |l| instance_exec(l, &entry) }
        else
          entry
        end
      end.compact_blank.uniq
    end

    def pages
      respond_to do |format|
        format.xml { render xml: pages_sitemap.to_xml }
      end
    end

    private

    def pages_sitemap
      pages = Page.published.where.not(skip_index: true)
                  .localized(content_locale)

      PagesCore::Sitemap.new do |map|
        pages.each { |p| map.add(page_url(p.locale, p), lastmod: p.updated_at) }
      end
    end

    def locales
      if PagesCore.config.locales
        PagesCore.config.locales.keys
      else
        [I18n.default_locale]
      end
    end
  end
end
