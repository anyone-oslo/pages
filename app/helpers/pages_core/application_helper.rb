# encoding: utf-8

# Methods added to this helper will be available to all templates in the application.
module PagesCore::ApplicationHelper
  include ActionView::Helpers::AssetTagHelper
  include DynamicImage::Helper
  include PagesCore::HeadTagsHelper

  def page_link(page, options={})
    options[:locale] ||= @locale
    page.localize(options[:locale]) do |p|
      options[:title] ||= p.name.to_s
      if options.has_key? :unless
        options[:if] = (options[:unless]) ? false : true
      end
      if options.has_key?(:if) && !(options[:if])
        return options[:title]
      end
      if p.redirects?
        link_to options[:title], p.redirect_path(locale: options[:locale]), class: options[:class]
      else
        link_to options[:title], page_path(options[:locale], p), class: options[:class]
      end
    end
  end

  def page_url(page_or_locale, page=nil, options={})
    if page
      locale = page_or_locale
    else
      ActiveSupport::Deprecation.warn "Calling page_url without locale is deprecated"
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
end
