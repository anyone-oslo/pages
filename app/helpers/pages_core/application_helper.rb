# encoding: utf-8

# Methods added to this helper will be available to all templates in the application.
module PagesCore::ApplicationHelper
  include DynamicImage::DynamicImageHelper
  include PagesCore::PluginAssetsHelper
  include PagesCore::VideoHelper
  include PagesCore::HeadTagsHelper

  def indent(string, level=0)
    indent_string = ""; level.times{indent_string += "\t"}
    string.split("\n").map{|line| "#{indent_string}#{line}"}.join("\n")
  end

  def is_page_route?(options={})
    (options[:controller] == 'pages' && options[:action] =~ /^(index|show)$/) ? true : false
  end

  def hash_for_translated_route(options, target_locale)
    if is_page_route?(options)
      if options[:id].kind_of?(Page)
        page = options[:id]
      elsif options[:id]
        page = Page.find(options[:id]) rescue nil
      elsif @page
        page = @page
      end
      if page
        options = options.merge(:id => page.localize(target_locale).to_param, :action => 'show')
      end
    end
    options = options.merge({locale: target_locale})
  end

  def smart_time(time, options={})
    options.symbolize_keys!
    options[:include_distance] ||= false
    options[:always_include_time] ||= false

    if options[:skip_prefix]
      date_string = ""
    else
      date_string = (time.to_date == Time.now.to_date) ? "at " : "on "
    end

    if time.to_date == Time.now.to_date
      date_string += time.strftime("%H:%M")
    elsif time.year == Time.now.year
      date_string += time.strftime("%b %d")
      date_string += time.strftime(" at %H:%M") if options[:always_include_time]
    else
      date_string += time.strftime("%b %d %Y")
      date_string += time.strftime(" at %H:%M") if options[:always_include_time]
      options[:include_distance] = false
    end

    date_string += " (" + time_ago_in_words( time ) + " ago)" if options[:include_distance]

    date_string
  end

  def page_link(page, options={})
    if options[:language]
      ActiveSupport::Deprecation.warn ":language option is deprecated, use :locale"
    end
    options[:locale] ||= options[:language] ||= @locale
    page.localize(options[:locale]) do |p|
      options[:title] ||= p.name.to_s
      if options.has_key? :unless
        options[:if] = (options[:unless]) ? false : true
      end
      if options.has_key?(:if) && !(options[:if])
        return options[:title]
      end
      if p.redirects?
        link_to options[:title], p.redirect_to_options({locale: p.locale}), :class => options[:class]
      else
        link_to options[:title], page_path(options[:locale], p), :class => options[:class]
      end
    end
  end

  def page_url(page, options={})
    if options[:language]
      ActiveSupport::Deprecation.warn ":language option is deprecated, use :locale"
    end
    options[:locale] ||= options[:language] ||= @locale
    page.localize(options[:locale]) do |p|
      if p.redirects?
        url_for p.redirect_to_options(options.merge({locale: p.locale}))
      else
        super options[:locale], p
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

  # Generate HTML for a field, with label and optionally description and errors.
  #
  # The options are:
  # * <tt>:description</tt>: Description of the field
  # * <tt>:errors</tt>:      Error messages for the attribute
  #
  # An example:
  #   <%= form_for @user do |f| %>
  #     <%= labelled_field f.text_field(:username), "Username",
  #                        :description => "Choose your username, minimum 4 characters",
  #                        :errors => @user.errors[:username] %>
  #     <%= submit_tag "Save" %>
  #   <% end %>
  #
  def labelled_field(field, label=nil, options={})
    options = {
      :field_tag => 'p'
    }.merge(options)
    if options[:errors] && options[:errors].any?
      output  = "<#{options[:field_tag]} class=\"field field_with_errors\">"
    else
      output  = "<#{options[:field_tag]} class=\"field\">"
    end
    output += "<label>#{label}" if label
    if options[:errors] && options[:errors].any?
      error = options[:errors]
      error = error.last if error.kind_of? Array
      output += ' <span class="error">' + error.to_s[] + '</span>'
    end
    output += "</label>" if label
    output += options[:description] + "<br />" if options[:description]
    output += field
    output += "</#{options[:field_tag]}>"
  end


    # Truncate string to max_length, retaining words. If the first word is shorter than max_length,
    # it will be shortened. An optional end_string can be supplied, which will be appended to the
    # string if it has been truncated.
  def truncate(string, max_length, end_string='')
      words = string.split(' ')
      new_words = [words.shift]
      while words.length > 0 && (new_words.join(' ').length + words.first.length) < max_length
          new_words << words.shift
        end
        new_string = new_words.join(' ')
        new_string = new_string[0...max_length] if new_string.length > max_length
        new_string += end_string unless new_string == string
        return new_string
    end

  def unique_page(page_name, &block)
    locale = @locale || Language.default
    page = Page.where(:unique_name => page_name).first
    if page && block_given?
      output = capture(page, &block)
      concat(output)
    end
    (page) ? page.localize(locale) : nil
  end

  # Sets a page title
  def page_title(title)
    @page_title = title
  end

end
