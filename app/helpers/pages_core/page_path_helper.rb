# encoding: utf-8

module PagesCore
  module PagePathHelper
    def page_path(locale, page, options = {})
      page.localize(locale) do |p|
        if p.full_path? && PagesCore.config.localizations?
          "/#{locale}/" + URI.escape(p.full_path)
        elsif p.full_path?
          "/" + URI.escape(p.full_path)
        else
          super(locale, p, options)
        end
      end
    end

    def page_url(page_or_locale, page = nil, opts = {})
      locale, page = page_url_locale_and_page(page_or_locale, page, opts)
      page.localize(locale) do |p|
        if p.redirects?
          p.redirect_path(locale: locale)
        elsif p.full_path
          "#{request.protocol}#{request.host_with_port}" + page_path(locale, p)
        else
          super(locale, p, opts)
        end
      end
    end

    private

    def page_url_locale_and_page(page_or_locale, page, opts)
      return [page_or_locale, page] if page
      ActiveSupport::Deprecation.warn(
        "Calling page_url without locale is deprecated"
      )
      [(opts[:locale] || @locale), page_or_locale]
    end
  end
end
