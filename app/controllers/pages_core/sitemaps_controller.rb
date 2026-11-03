# frozen_string_literal: true

module PagesCore
  class SitemapsController < ApplicationController
    include PagesCore::PagePathHelper

    static_cache :index, :pages

    before_action :require_locale, only: :pages

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
      render_sitemap do |map|
        Page.published.where.not(skip_index: true)
            .localized(content_locale).find_each do |page|
          next if page.redirects?

          map.add(page_url(page.locale, page), lastmod: page.updated_at)
        end
      end
    end

    private

    def locales
      if PagesCore.config.locales
        PagesCore.config.locales.keys
      else
        [I18n.default_locale]
      end
    end

    def require_locale
      render_error 404 unless locales.map(&:to_s).include?(params[:locale])
    end

    def render_sitemap(&)
      respond_to do |format|
        format.xml { render xml: PagesCore::Sitemap.new(&).to_xml }
      end
    end
  end
end
