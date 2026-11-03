# frozen_string_literal: true

module PagesCore
  module PagePathHelper
    def page_path(locale, page, options = {})
      page.localize(locale) do |p|
        unless p.full_path?
          return super(locale, p, options) unless options[:page]

          return paginated_page_path(locale, p, options[:page],
                                     options.except(:page))
        end

        (PagesCore.config.localizations? ? "/#{locale}/" : "/") +
          escape_page_path(p.full_path) + path_suffix(options)
      end
    end

    def page_url(locale, page, opts = {})
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
      redirect = page.redirect_path(locale:)
      return redirect if %r{^https?://}.match?(redirect)

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

    def path_suffix(opts)
      paginated_section(opts) + (html_format?(opts) ? "" : ".#{opts[:format]}")
    end

    def paginated_section(opts)
      return "" unless opts[:page]

      "/page/#{opts[:page]}"
    end
  end
end
