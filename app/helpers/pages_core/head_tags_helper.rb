# encoding: utf-8

module PagesCore::HeadTagsHelper
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
    # Evaluate the given block first
    output_block = block_given? ? capture(&block) : ''

    # Get options
    language_definition = Language.definition(@locale).iso639_1 || "en"
    unless options.has_key?(:title)
      options[:title] = PagesCore.config(:site_name)
      if @page_title && @page_title != options[:title]
        options[:title] = "#{@page_title} - #{options[:title]}"
      end
    end

    # Build HTML
    output  = "<!doctype html>\n"
    output += "<html lang=\"#{language}\">"
    output += "<head>\n"
    output += "	<meta charset=\"utf-8\">\n"
    output += "	<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n"

    output += "	<title>#{options[:title]}</title>\n"
    if options.has_key? :stylesheet
      output += indent(stylesheet_link_tag(*options[:stylesheet]), 1) + "\n"
    end

    if options.has_key?(:javascript)
      Array(options[:javascript]).each do |js|
        if js.kind_of?(Array)
          output += "\t" + javascript_include_tag(js.first, js.last) + "\n"
        else
          output += "\t" + javascript_include_tag(js) + "\n"
        end
      end
    end

    if options[:feed_tags] && options[:feed_tags] == :include_hidden
      output += indent(feed_tags(:include_hidden => true), 1)
    elsif options[:feed_tags]
      output += indent(feed_tags, 1)
    end

    output += "\n"

    # META description
    if @meta_description
      options[:meta_description] = @meta_description
    elsif @page && !@page.excerpt.to_s.empty?
      options[:meta_description] = @page.excerpt.to_s
    end
    if options[:meta_description]
      meta_description = html_escape(strip_tags(options[:meta_description]))
      output += "\t<meta name=\"description\" content=\"#{meta_description}\" />\n"
    end
    # META keywords
    if @meta_keywords
      options[:meta_keywords] = @meta_keywords
    elsif @page && @page.tags.any?
      options[:meta_keywords] = @page.tag_list
    end
    if options[:meta_keywords]
      meta_keywords = html_escape(strip_tags(options[:meta_keywords]))
      output += "\t<meta name=\"keywords\" content=\"#{options[:meta_keywords]}\" />\n"
    end

    if @meta_image
      options[:meta_image] = @meta_image
    elsif @page && @page.image
      options[:meta_image] = @page.image
    elsif options[:default_meta_image]
      options[:meta_image] = options[:default_meta_image]
    end

    if options[:meta_image]
      if options[:meta_image].kind_of?(Image)
        output += "\t<link rel=\"image_src\" href=\"" + dynamic_image_url(options[:meta_image], :size => '400x', :only_path => false) + "\" />\n"
      else
        output += "\t<link rel=\"image_src\" href=\"" + options[:meta_image] + "\" />\n"
      end
    end


    # Facebook meta tags
    output += "<meta property=\"og:type\" content=\"website\" />\n"
    output += "<meta property=\"og:site_name\" content=\"#{PagesCore.config(:site_name)}\" />\n"
    output += "<meta property=\"og:title\" content=\"#{options[:title]}\" />\n"
    if options[:meta_image]
      if options[:meta_image].kind_of?(Image)
        output += "<meta property=\"og:image\" content=\""+dynamic_image_url(options[:meta_image], :size => '400x', :only_path => false)+"\" />\n"
      else
        output += "<meta property=\"og:image\" content=\"" + options[:meta_image] + "\" />\n"
      end
    end
    if options[:meta_description]
      meta_description = html_escape(strip_tags(options[:meta_description]))
      output += "<meta property=\"og:description\" content=\"#{meta_description}\" />\n"
    end

    output += output_block unless output_block.blank?
    output += "</head>\n"

    output.html_safe
  end

  def feed_tags(options={})
    feeds = Page.enabled_feeds(@locale, options)
    output = ''
    if feeds && feeds.length > 1
      output += "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"#{PagesCore.config(:site_name)}\" href=\""+formatted_pages_url(@locale, format: :rss)+"\" />\n"
    end
    output += feeds.map{ |p| "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"#{PagesCore.config(:site_name)}: #{p.name.to_s}\" href=\""+page_url( p, :only_path => false, :format => :rss )+"\" />" }.join("\n")
    output
  end

end
