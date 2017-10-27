# Methods added to this helper will be available to all templates
# in the application.
module PagesCore
  module ApplicationHelper
    include PagesCore::HeadTagsHelper
    include PagesCore::ImagesHelper
    include PagesCore::MetaTagsHelper
    include PagesCore::OpenGraphTagsHelper
    include PagesCore::PagePathHelper

    def page_link(page, options = {})
      link_locale = options[:locale] || locale
      page.localize(link_locale) do |p|
        title = options[:title] || p.name.to_s
        return title unless conditional_options?(options)
        link_to(title, page_link_path(link_locale, p), class: options[:class])
      end
    end

    def unique_page(page_name, &block)
      locale = @locale || I18n.default_locale.to_s
      page = Page.where(unique_name: page_name).first
      if page && block_given?
        output = capture(page.localize(locale), &block)
        concat(output)
      end
      page ? page.localize(locale) : nil
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

    def page_link_path(locale, page)
      if page.redirects?
        page.redirect_path(locale: locale)
      else
        page_path(locale, page)
      end
    end
  end
end
