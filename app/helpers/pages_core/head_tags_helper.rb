# encoding: utf-8

module PagesCore::HeadTagsHelper

  def include_stylesheet(source, options={})
    @include_stylesheets ||= []
    @include_stylesheets << [source, options]
  end

  def include_javascript(source, options={})
    @include_javascripts ||= []
    @include_javascripts << [source, options]
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
    # Evaluate the given block first
    output_block = block_given? ? capture(&block) : ''

    # Get options
    options[:language] ||= @language
    options[:charset]  ||= "utf-8"
    options[:author]   ||= "Manual design (manualdesign.no)"
    options[:doctype]  ||= :xhtml
    language_definition = Language.definition( options[:language] ).iso639_1 || "en"
    unless options.has_key?( :title )
      options[:title] = PagesCore.config(:site_name)
      if @page_title
        if options[:prepend_page_title]
          options[:title] = "#{@page_title} - #{options[:title]}"
        else
          options[:title] = "#{options[:title]} - #{@page_title}"
        end
      end
    end

    # Build HTML
    output  = ""
    if options[:doctype] == :xhtml
      output += "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"
      output += "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"#{language_definition}\" lang=\"#{language_definition}\">\n"
      output += "<head>\n"
      output += "	<meta http-equiv=\"Content-Type\" content=\"text/html; charset=#{options[:charset]}\" />\n"
      output += "	<meta http-equiv=\"Content-Language\" content=\"#{language_definition}\" />\n"
      output += "	<meta name=\"author\" content=\"#{options[:author]}\" />\n"
    elsif options[:doctype] == :html5
      output += "<!doctype html>\n"
      if options.has_key?(:modernizr)
        output += "<!--[if lt IE 7]>      <html class=\"no-js lt-ie9 lt-ie8 lt-ie7\" lang=\"#{language_definition}\"> <![endif]-->"
        output += "<!--[if IE 7]>         <html class=\"no-js lt-ie9 lt-ie8\" lang=\"#{language_definition}\"> <![endif]-->"
        output += "<!--[if IE 8]>         <html class=\"no-js lt-ie9\" lang=\"#{language_definition}\"> <![endif]-->"
        output += "<!--[if gt IE 8]><!--> <html class=\"no-js\" lang=\"#{language_definition}\"> <!--<![endif]-->"
      else
        output += "<!--[if lt IE 7]>      <html class=\"lt-ie9 lt-ie8 lt-ie7\" lang=\"#{language_definition}\"> <![endif]-->"
        output += "<!--[if IE 7]>         <html class=\"lt-ie9 lt-ie8\" lang=\"#{language_definition}\"> <![endif]-->"
        output += "<!--[if IE 8]>         <html class=\"lt-ie9\" lang=\"#{language_definition}\"> <![endif]-->"
        output += "<!--[if gt IE 8]><!--> <html lang=\"#{language_definition}\"> <!--<![endif]-->"
      end
      output += "<head>\n"
      output += "	<meta charset=\"#{options[:charset]}\">\n"
      output += "	<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\">\n"
      output += "	<meta name=\"author\" content=\"#{options[:author]}\">\n"
    end
    output += "	<title>#{options[:title]}</title>\n"
    if options.has_key? :stylesheet
      output += indent(stylesheet_link_tag(*options[:stylesheet]), 1) + "\n"
    end

    if @include_stylesheets
      output += @include_stylesheets.map do |source, source_options|
        ie = source_options.delete(:ie)
        source_output = stylesheet_link_tag(source, source_options)
        source_output = "<!--[if #{ie}]>#{source_output}<![endif]-->" if ie
        indent(source_output, 1)
      end.join("\n")
      output += "\n"
    end

    #output += "\t"+javascript_include_tag(
    if options.has_key?(:javascript)
      Array(options[:javascript]).each do |js|
        if js.kind_of?(Array)
          output += "\t" + javascript_include_tag(js.first, js.last) + "\n"
        else
          output += "\t" + javascript_include_tag(js) + "\n"
        end
      end
    end
    #output += indent(javascript_include_tag(*options[:javascript] ), 1) + "\n" if options.has_key? :javascript

    if @include_javascripts
      output += @include_javascripts.map do |source, source_options|
        ie = source_options.delete(:ie)
        source_output = javascript_include_tag(source)
        source_output = "<!--[if #{ie}]>#{source_output}<![endif]-->" if ie
        indent(source_output, 1)
      end.join("\n")
      output += "\n"
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
    elsif @page && @page.tags?
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
    end

    if options[:meta_image]
      if options[:meta_image].kind_of?(Image)
        output += "\t<link rel=\"image_src\" href=\"" + dynamic_image_url(options[:meta_image], :size => '400x', :only_path => false) + "\" />\n"
      else
        output += "\t<link rel=\"image_src\" href=\""  +options[:meta_image] + "\" />\n"
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

    output += output_block
    output += "</head>\n"

    # Inject HTML
    concat(output)
    return ""
  end

  def feed_tags(options={})
    feeds = Page.enabled_feeds(@language, options)
    output = ''
    if feeds && feeds.length > 1
      output += "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"#{PagesCore.config(:site_name)}\" href=\""+formatted_pages_url(:language => @language, :format => :rss)+"\" />\n"
    end
    output += feeds.map{ |p| "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"#{PagesCore.config(:site_name)}: #{p.name.to_s}\" href=\""+page_url( p, :only_path => false, :format => :rss )+"\" />" }.join("\n")
    output
  end

end
