# encoding: utf-8

module PagesCore::HeadTagsHelper

  # Sets a default image to use for meta tags. Supports
  # both paths and Image objects.
  #
  #  default_meta_image image_path("facebook-share.png")
  #  default_meta_image root_page.image
  #
  def default_meta_image(*args)
    if args.any?
      @default_meta_image = args.first
    else
      @default_meta_image
    end
  end

  # Returns true if default meta image has been set.
  def default_meta_image?
    default_meta_image ? true : false
  end

  # Sets a document title.
  #
  #  document_title "Dashboard"
  #
  def document_title(*args)
    if args.any?
      @document_title = args.first
    else
      safe_join([@document_title, PagesCore.config(:site_name)].compact.uniq, " - ")
    end
  end
  alias_method :page_title, :document_title

  # Returns true if document title has been set.
  def document_title?
    @document_title ? true : false
  end

  # Generates links for all RSS feeds. Specify
  # :include_hidden to also include hidden pages.
  #
  #  feed_tags
  #  feed_tags include_hidden: true
  #
  def feed_tags(options={})
    feeds = Page.enabled_feeds(@locale, options)
    if feeds.any?
      feed_tags = [rss_link_tag(PagesCore.config(:site_name), pages_url(@locale, format: :rss))]
      if feeds.count < 1
        feed_tags += feeds.map do |page|
          rss_link_tag("#{PagesCore.config(:site_name)}: #{page.name}", page_url(@locale, page, format: :rss))
        end
      end
      safe_join(feed_tags, "\n")
    end
  end

  # Outputs Google Analytics tracking code.
  #
  #  google_analytics_tags "UA-12345678-1"
  #
  def google_analytics_tags(account_id)
    javascript_tag("
      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', '#{account_id}']);
      _gaq.push(['_trackPageview']);

      (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();
    ")
  end

  # Outputs a HTML5 doctype and head tags, with document title
  # and relevant meta tags. Takes a block which will be placed
  # inside <head>.
  #
  #  <%= head_tag do %>
  #    <%= stylesheet_link_tag "application" %>
  #    <%= javascript_include_tag "application" %>
  #    <%= feed_tags %>
  #  <% end %>
  #
  def head_tag(options={}, &block)
    deprecate_head_tag_options(options, caller)

    # The block output must be captured first
    block_output = block_given? ? capture(&block) : nil

    "<!doctype html>\n<html lang=\"#{I18n.locale}\">".html_safe +
    content_tag(:head) do
      safe_join([
        tag(:meta, charset: "utf-8"),
        tag(:meta, "http-equiv" => "X-UA-Compatible", :content => "IE=edge"),
        content_tag(:title, document_title),
        (tag(:meta, name: "description", content: meta_description) if meta_description?),
        (tag(:meta, name: "keywords", content: meta_keywords) if meta_keywords?),
        (tag(:link, rel: "image_src", href: meta_image) if meta_image?),
        (deprecated_head_tags(options) if options.any?),
        open_graph_tags,
        csrf_meta_tags,
        block_output
      ].compact, "\n")
    end
  end

  # Sets a description for meta tags.
  #
  #   meta_description "This is an awesome site"
  #
  def meta_description(*args)
    if args.any?
      @meta_description = args.first
    else
      description = @meta_description
      if @page && !@page.excerpt.empty?
        description ||= @page.excerpt
      end
      strip_tags(description)
    end
  end

  # Returns true if meta description has been set.
  def meta_description?
    !meta_description.blank?
  end

  # Sets an image to use for meta tags. Supports
  # both paths and Image objects.
  #
  #   meta_image image_path("facebook-share.png")
  #   meta_image @page.image
  #
  def meta_image(*args)
    if args.any?
      @meta_image = args.first
    else
      image   = @meta_image
      image ||= @page.try(&:image)
      image ||= default_meta_image
      if image.kind_of?(Image)
        dynamic_image_url(image, :size => '1200x', only_path: false)
      else
        image
      end
    end
  end

  # Returns true if meta image has been set.
  def meta_image?
    !meta_image.blank? || default_meta_image?
  end

  # Sets keywords for meta tags.
  #
  #   meta_keywords "cialis viagra"
  #
  def meta_keywords(*args)
    if args.any?
      @meta_keywords = Array(args.first).join(" ")
    else
      keywords = @meta_keywords
      if @page && @page.tags.any?
        keywords ||= @page.tag_list
      end
      strip_tags(keywords)
    end
  end

  # Returns true if meta keywords have been set.
  def meta_keywords?
    !meta_keywords.blank?
  end

  # Outputs Open Graph tags for Facebook.
  def open_graph_tags
    properties = {
      type:        "website",
      site_name:   PagesCore.config(:site_name),
      title:       document_title,
      image:       (meta_image if meta_image?),
      description: (meta_description if meta_description?)
    }
    safe_join(properties.delete_if { |_, content| content.nil? }.map do |name, content|
      tag(:meta, property: "og:#{name}", content: content)
    end, "\n")
  end

  # Generates a link to an RSS feed.
  #
  #  rss_link_tag "My feed", "feed.rss"
  #
  def rss_link_tag(title, href)
    tag(:link, rel: "alternate", type: "application/rss+xml", title: title, href: href)
  end

  # Outputs Typekit tags.
  #
  #  typekit_tags "aadgrag"
  #
  def typekit_tags(kit_id)
    safe_join([
      javascript_include_tag("http://use.typekit.com/#{kit_id}.js"),
      javascript_tag("try{Typekit.load();}catch(e){}")
    ], "\n")
  end

  protected

  def deprecated_head_tags(options={})
    tags << []

    if options.has_key?(:stylesheet)
      tags << stylesheet_link_tag(*options[:stylesheet])
    end

    if options.has_key?(:javascript)
      Array(options[:javascript]).each do |js|
        if js.kind_of?(Array)
          tags << javascript_include_tag(js.first, js.last)
        else
          tags << javascript_include_tag(js)
        end
      end
    end

    if options[:feed_tags] && options[:feed_tags] == :include_hidden
      tags << feed_tags(:include_hidden => true)
    elsif options[:feed_tags]
      tags << feed_tags
    end

    safe_join(tags, "\n")
  end

  def deprecate_head_tag_options(options, callstack)
    if options.has_key?(:title)
      ActiveSupport::Deprecation.warn ":title option for head_tag is deprecated, use the document_title helper", callstack
      document_title options[:title]
    end

    if options.has_key?(:meta_description)
      ActiveSupport::Deprecation.warn ":meta_description option for head_tag is deprecated, use the meta_description helper", callstack
      meta_description options[:meta_description]
    end

    if options.has_key?(:meta_keywords)
      ActiveSupport::Deprecation.warn ":meta_keywords option for head_tag is deprecated, use the meta_keywords helper", callstack
      meta_keywords options[:meta_keywords]
    end

    if options.has_key?(:meta_image)
      ActiveSupport::Deprecation.warn ":meta_image option for head_tag is deprecated, use the meta_image helper", callstack
      meta_image options[:meta_image]
    end

    if options.has_key?(:default_meta_image)
      ActiveSupport::Deprecation.warn ":default_meta_image option for head_tag is deprecated, use the default_meta_image helper", callstack
      default_meta_image options[:default_meta_image]
    end

    if options.has_key?(:javascript)
      ActiveSupport::Deprecation.warn ":javascript option for head_tag is deprecated, use javascript_include_tag in the block", callstack
    end

    if options.has_key?(:stylesheet)
      ActiveSupport::Deprecation.warn ":stylesheet option for head_tag is deprecated, use stylesheet_link_tag in the block", callstack
    end

    if options.has_key?(:feed_tags)
      ActiveSupport::Deprecation.warn ":feed_tags option for head_tag is deprecated, use the feed_tags helper in the block", callstack
    end
  end

end
