# frozen_string_literal: true

module PagesCore
  module PagePathHelper
    def page_path(locale, page, options = {})
      page.localize(locale) do |p|
        return super(locale, p, options) unless p.full_path?

        (PagesCore.config.localizations? ? "/#{locale}/" : "/") +
          escape_page_path(p.full_path) +
          (html_format?(options) ? "" : ".#{options[:format]}") +
          paginated_section(options)
      end
    end

    def page_url(page_or_locale, page = nil, opts = {})
      locale, page = page_url_locale_and_page(page_or_locale, page, opts)

      page.localize(locale) do |p|
        if p.redirects? && html_format?(opts)
          page_redirect_url(locale, p)
        elsif p.full_path
          base_page_url + page_path(locale, p, opts)
        else
          super(locale, p, opts)
        end
      end
    end

    private

    def page_redirect_url(locale, page)
      redirect = page.redirect_path(locale: locale)
      return redirect if redirect =~ %r{^https?://}

      base_page_url + redirect
    end

    def base_page_url
      "#{request.protocol}#{request.host_with_port}"
    end

    def html_format?(opts)
      opts[:format].blank? || opts[:format].to_sym == :html
    end

    def escape_page_path(path)
      path.split("/").map { |s| CGI.escape(s) }.join("/")
    end

    def page_url_locale_and_page(page_or_locale, page, opts)
      return [page_or_locale, page] if page

      ActiveSupport::Deprecation.warn(
        "Calling page_url without locale is deprecated"
      )
      [opts[:locale] || content_locale, page_or_locale]
    end

    def paginated_section(opts)
      return "" unless opts[:page]

      "/page/#{opts[:page]}"
    end
  end
end
