# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	#include ActsAsDynamicImage::Helper
	include VideoHelper
	
	def feed_tags(options={})
		feeds = Page.enabled_feeds(@language, options)
		output = ''
		if feeds && feeds.length > 1
			output += "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"#{PagesCore.config(:site_name)}\" href=\""+formatted_pages_url(:language => @language, :format => :rss)+"\" />\n"
		end
		output += feeds.map{ |p| "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"#{PagesCore.config(:site_name)}: #{p.name.to_s}\" href=\""+page_url( p, :only_path => false, :format => :rss )+"\" />" }.join("\n")
		output
	end

	def i18n( string )
		language = @language || Language.default
		begin
			translated = @@i18n_table[string.downcase][language]
			translated || string
		rescue
			string
		end
	end
	
	def include_stylesheet(source, options={})
		@include_stylesheets ||= []
		@include_stylesheets << [source, options]
	end

	def include_javascript(source, options={})
		@include_javascripts ||= []
		@include_javascripts << [source, options]
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
				output += "<!--[if lt IE 7]><html class=\"no-js ie6\" lang=\"#{language_definition}\"><![endif]-->\n"
				output += "<!--[if IE 7]><html class=\"no-js ie7\" lang=\"#{language_definition}\"><![endif]-->\n"
				output += "<!--[if IE 8]><html class=\"no-js ie8\" lang=\"#{language_definition}\"><![endif]-->\n"
				output += "<!--[if gt IE 8]><!--><html class=\"no-js\" lang=\"#{language_definition}\"><!--<![endif]-->\n"
			else
				output += "<!--[if lt IE 7]><html class=\"ie6\" lang=\"#{language_definition}\"><![endif]-->\n"
				output += "<!--[if IE 7]><html class=\"ie7\" lang=\"#{language_definition}\"><![endif]-->\n"
				output += "<!--[if IE 8]><html class=\"ie8\" lang=\"#{language_definition}\"><![endif]-->\n"
				output += "<!--[if gt IE 8]><!--><html lang=\"#{language_definition}\"><!--<![endif]-->\n"
			end
			output += "<head>\n"
			output += "	<meta charset=\"#{options[:charset]}\">\n"
			output += "	<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\">\n"
			output += "	<meta name=\"author\" content=\"#{options[:author]}\">\n"
		end
		output += "	<title>#{options[:title]}</title>\n"
		output += indent(stylesheet_link_tag(*options[:stylesheet] ), 1) + "\n"    if options.has_key? :stylesheet

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
			options[:javascript].each do |js|
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
		if page = @page
		    # META description
		    if @meta_description
		        options[:meta_description] = @meta_description
	        elsif !page.excerpt.to_s.empty?
	            options[:meta_description] = page.excerpt.to_s
            end
		    if options[:meta_description]
				output += "\t<meta name=\"description\" content=\"#{options[:meta_description]}\" />\n"
			end
			# META keywords
		    if @meta_keywords
		        options[:meta_keywords] = @meta_keywords
	        elsif !page.tags?
	            options[:meta_keywords] = page.tag_list
            end
		    if options[:meta_keywords]
				output += "\t<meta name=\"keywords\" content=\"#{options[:meta_keywords]}\" />\n"
			end
			if page.image
				# Facebook likes this
				output += "\t<link rel=\"image_src\" href=\""+dynamic_image_url(page.image, :size => '400x', :only_path => false)+"\" />\n"
			end	
		end
		output += output_block
		output += "</head>\n"

		# Inject HTML
		concat(output)
		return ""
	end
	
	def indent( string, level=0 )
		indent_string = ""; level.times{ indent_string += "\t" }
		string.split("\n").map{ |line| "#{indent_string}#{line}" }.join("\n")
	end
	
	
	def is_page_route?( options={} )
		( options[:controller] == 'pages' && options[:action] =~ /^(index|show)$/ ) ? true : false
	end
	
	def hash_for_translated_route( options, target_language )
		if is_page_route? options
			if options[:id].kind_of? Page
				page = options[:id]
			elsif options[:id]
				page = Page.find( options[:id] ) rescue nil
				page ||= Page.find_by_slug_and_language( options[:id], @language )
			elsif @page
				page = @page
			end
			if page
				options = options.merge( :id => page.translate( target_language ).to_param, :action => 'show' )
			end
		end
		options = options.merge( { :language => target_language } )
	end
	
	def page_file_link(file, options={})
		options[:language] ||= @language
		if file.format?
			formatted_page_file_path(@language,file.page,file, :format => file.format)
		else
			page_file_path(@language,file.page,file)
		end
	end

	def translated_link( name, new_language )
		language = @language || Language.default
		overwrite_params = {}
		overwrite_params[:language] = new_language
		if( params[:slug] )
			page = Page.find_by_slug_and_language( params[:slug], language )
			page.working_language = new_language
			overwrite_params[:slug] = page.slug.to_s
			if overwrite_params[:slug] == ""
				overwrite_params[:slug] = nil
			end
		end
		link_to_unless_current name, :overwrite_params => overwrite_params
	end
	
	def smart_time( time, options={} )
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
	
	def fragment( name )
		Partial.find_by_name(name).translate(@language).body.to_html rescue ""
	end
	alias_method :partial, :fragment
	
	def page_link( page, options={} ) 
		page.translate( @language ) do |p|
			options[:title] ||= p.name.to_s
			if options.has_key? :unless
				options[:if] = ( options[:unless] ) ? false : true
			end
			if options.has_key?( :if ) && !( options[:if] )
				return options[:title]
			end
			if p.redirects? 
				#raise p.redirect_to_options( { :language => p.working_language } ).inspect
				link_to options[:title], p.redirect_to_options( { :language => p.working_language } ), :class => options[:class]
			else
				link_to options[:title], { :controller => 'pages', :action => :show, :language => p.working_language, :id => p }, :class => options[:class]
			end
		end
	end
	
	def page_url( page, options={} )
		options[:language] ||= @language
		page.translate(options[:language]) do |p|
			if p.redirects? 
				url_options = p.redirect_to_options(options.merge({:language => p.working_language}))
			else
				url_options = options.merge({:controller => 'pages', :action => :show, :language => p.working_language, :id => p.to_param})
			end
			url_for url_options
		end
	end
	
	
	def dynamic_lightbox_image( image, options={} )
		options = { :fullsize => '640x480' }.merge( options ).symbolize_keys!
		fullsize = options[:fullsize]
		options.delete :fullsize
		if options[:set]
			rel = "lightbox[#{options[:set]}]"
			options.delete :set
		else
			rel = "lightbox"
		end
		
		link_to( 
			dynamic_image_tag( image, options ), 
			dynamic_image_url( image, :size => fullsize, :crop => false ), 
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
	#   <% form_for 'user', @user do |f| %>
	#     <%= labelled_field f.text_field( :username ), "Username", 
	#                        :description => "Choose your username, minimum 4 characters", 
	#                        :errors => @user.errors[:username] %>
	#     <%= submit_tag "Save" %>
	#   <% end %>
	#
	def labelled_field(field, label=nil, options={})
		options = {
			:field_tag => 'p'
		}.merge(options)
		if options[:errors]
			output  = "<#{options[:field_tag]} class=\"field field_with_errors\">"
		else
			output  = "<#{options[:field_tag]} class=\"field\">"
		end
		output += "<label>#{label}" if label
		if options[:errors]
			error = options[:errors]
			error = error.last if error.kind_of? Array
			output += ' <span class="error">' + error.to_s[] + '</span>'
		end
		output += "</label>" if label
		output += options[:description] + "<br />" if options[:description]
		output += field
		output += "</#{options[:field_tag]}>"
	end
	

	# Generate HTML for a text area field.
	def labelled_body_field( field, label=nil, options={} )
		if options[:errors]
			error = options[:errors]
			error = error.last if error.kind_of? Array
		end
		error ||= nil
		render :partial => 'common/body_field', :locals => { :field => field, :label => label, :error => error }
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
		language = @language || Language.default
		page = Page.find_unique(page_name)
		if page && block_given?
			output = capture(page, &block)
			concat(output)
		end
		(page) ? page.translate(language) : nil
	end
	
	# Sets a page title
	def page_title(title)
		@page_title = title
	end

end
