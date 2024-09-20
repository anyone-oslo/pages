# frozen_string_literal: true

class SitemapsController < ApplicationController
  include PagesCore::PagePathHelper
  static_cache :show

  def show
    @sitemaps = locales.map { |l| sitemap_pages_url(l, format: :xml) }
  end

  private

  def locales
    if PagesCore.config.locales
      PagesCore.config.locales.keys
    else
      [I18n.default_locale]
    end
  end
end
