# encoding: utf-8

# Methods added to this helper will be available to all templates in the application.
module PagesCore::ApplicationHelper
  include ActionView::Helpers::AssetTagHelper
  include DynamicImage::DynamicImageHelper
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
        link_to options[:title], p.redirect_path(locale: options[:locale]), :class => options[:class]
      else
        link_to options[:title], page_path(options[:locale], p), :class => options[:class]
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

  def dynamic_lightbox_image(image, options={})
    options = {:fullsize => '640x480'}.merge(options).symbolize_keys!
    fullsize = options[:fullsize]
    options.delete :fullsize
    if options[:set]
      rel = "lightbox[#{options[:set]}]"
      options.delete :set
    else
      rel = "lightbox"
    end

    link_to(
      dynamic_image_tag(image, options),
      dynamic_image_url(image, :size => fullsize, :crop => false),
      :title => options[:title] || image.name,
      :rel => rel,
      :target => '_blank'
    )
  end

  def unique_page(page_name, &block)
    locale = @locale || I18n.default_locale.to_s
    page = Page.where(:unique_name => page_name).first
    if page && block_given?
      output = capture(page, &block)
      concat(output)
    end
    (page) ? page.localize(locale) : nil
  end
end
