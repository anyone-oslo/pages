# encoding: utf-8

# Methods added to this helper will be available to all templates
# in the application.
module PagesCore
  module ApplicationHelper
    include PagesCore::HeadTagsHelper
    include PagesCore::ImagesHelper

    def page_link(page, options = {})
      link_locale = options[:locale] || locale
      page.localize(link_locale) do |p|
        title = options[:title] || p.name.to_s
        return title unless conditional_options?(options)
        url = if p.redirects?
                p.redirect_path(locale: link_locale)
              else
                page_path(link_locale, p)
              end
        link_to(title, url, class: options[:class])
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
        else
          super locale, p, options
        end
      end
    end

    def unique_page(page_name, &block)
      locale = @locale || I18n.default_locale.to_s
      page = Page.where(unique_name: page_name).first
      if page && block_given?
        output = capture(page, &block)
        concat(output)
      end
      (page) ? page.localize(locale) : nil
    end

    private

    def conditional_options?(options = {})
      if options.key?(:if)
        options[:if]
      elsif options.key?(:unless)
        !options[:unless]
      else
        true
      end
    end
  end
end
