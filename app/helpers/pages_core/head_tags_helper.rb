# encoding: utf-8

module PagesCore::HeadTagsHelper
  def default_meta_image(image=nil)
    @default_meta_image = image if image
    @default_meta_image
  end

  def default_meta_image?
    default_meta_image ? true : false
  end

  def document_title(title=nil)
    @document_title = title if title
    [@document_title, PagesCore.config(:site_name)].compact.uniq.join(" - ")
  end
  alias_method :page_title, :document_title

  def document_title?
    @document_title ? true : false
  end

  def meta_description(description=nil)
    @meta_description = description if description
    description = @meta_description
    if @page && !@page.excerpt.empty?
      description ||= @page.excerpt
    end
    html_escape(strip_tags(description))
  end

  def meta_description?
    !meta_description.blank?
  end

  def meta_image(image=nil)
    @meta_image = image if image
    image   = @meta_image
    image ||= @page.try(&:image)
    image ||= default_meta_image
    if image.kind_of?(Image)
      dynamic_image_url(image, :size => '1200x', only_path: false)
    else
      image
    end
  end

  def meta_image?
    !meta_image.blank? || default_meta_image?
  end

  def meta_keywords(keywords=nil)
    @meta_keywords = keywords if keywords
    keywords = @meta_keywords
    if @page && @page.tags.any?
      keywords ||= @page.tag_list
    end
    html_escape(strip_tags(keywords))
  end

  def meta_keywords?
    !meta_keywords.blank?
  end

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

  def typekit_tags(kit_id)
    javascript_include_tag("http://use.typekit.com/#{kit_id}.js") +
    javascript_tag("try{Typekit.load();}catch(e){}")
  end

  def head_tag(options={}, &block)
    deprecate_head_tag_options(options, caller)

    # The block output must be captured first
    block_output = block_given? ? capture(&block) : ""

    output  = "<!doctype html>\n"
    output += "<html lang=\"#{iso638_1_locale}\">\n"
    output += "<head>\n"
    output += "<meta charset=\"utf-8\">\n"
    output += "<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n"
    output += "<title>#{document_title}</title>\n"

    if meta_description?
      output += "<meta name=\"description\" content=\"#{meta_description}\" />\n"
    end

    if meta_keywords?
      output += "<meta name=\"keywords\" content=\"#{meta_keywords}\" />\n"
    end

    if meta_image?
      output += "<link rel=\"image_src\" href=\"#{meta_image}\" />\n"
    end

    output += deprecated_head_tags(options) if options.any?
    output += open_graph_tags

    output += block_output
    output += "</head>\n"

    output.html_safe
  end

  def feed_tags(options={})
    feeds = Page.enabled_feeds(@locale, options)
    output = ''
    if feeds.any?
      output += "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"#{PagesCore.config(:site_name)}\" href=\""+formatted_pages_url(@locale, format: :rss)+"\" />\n"
    end
    output += feeds.map{ |p| "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"#{PagesCore.config(:site_name)}: #{p.name.to_s}\" href=\""+page_url( p, :only_path => false, :format => :rss )+"\" />" }.join("\n")
    output
  end

  def open_graph_tags
    output = ""
    output += "<meta property=\"og:type\" content=\"website\" />\n"
    output += "<meta property=\"og:site_name\" content=\"#{PagesCore.config(:site_name)}\" />\n"
    output += "<meta property=\"og:title\" content=\"#{document_title}\" />\n"
    output += "<meta property=\"og:image\" content=\"#{meta_image}\" />\n" if meta_image?
    output += "<meta property=\"og:description\" content=\"#{meta_description}\" />\n" if meta_description?
    output
  end

  protected

  def iso638_1_locale
    Language.definition(@locale).iso639_1 || "en"
  end

  def deprecated_head_tags(options={})
    output = ""

    if options.has_key?(:stylesheet)
      output += stylesheet_link_tag(*options[:stylesheet]) + "\n"
    end

    if options.has_key?(:javascript)
      Array(options[:javascript]).each do |js|
        if js.kind_of?(Array)
          output += javascript_include_tag(js.first, js.last) + "\n"
        else
          output += javascript_include_tag(js) + "\n"
        end
      end
    end

    if options[:feed_tags] && options[:feed_tags] == :include_hidden
      output += feed_tags(:include_hidden => true)
    elsif options[:feed_tags]
      output += feed_tags
    end

    output
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
