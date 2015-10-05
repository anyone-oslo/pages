# encoding: utf-8

module PagesCore
  module PagePathHelper
    def page_path(locale, page)
      page.localize(locale) do |p|
        if p.full_path?
          path = if PagesCore.config.localizations?
                   "/#{locale}/" + p.full_path
                 else
                   "/" + p.full_path
                 end
          if PagesCore.config.pages_path_scope?
            "/#{PagesCore.config.pages_path_scope}" + path
          else
            path
          end
        else
          super
        end
      end
    end

    def page_url(page_or_locale, page = nil, options = {})
      if page
        locale = page_or_locale
      else
        ActiveSupport::Deprecation.warn(
          "Calling page_url without locale is deprecated"
        )
        locale = options[:locale] || @locale
        page = page_or_locale
      end
      page.localize(locale) do |p|
        if p.redirects?
          p.redirect_path(locale: locale)
        elsif p.full_path
          "#{request.protocol}#{request.host_with_port}" + page_path(locale, p)
        else
          super locale, p, options
        end
      end
    end
  end
end
