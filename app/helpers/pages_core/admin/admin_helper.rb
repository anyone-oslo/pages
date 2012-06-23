# encoding: utf-8

module PagesCore::Admin::AdminHelper

	def tag_editor_for(form_helper, item, field_name = :serialized_tags, options = {})
		options[:tags]        ||= Tag.tags_and_suggestions_for(item, :limit => 20)
		options[:tagged]      ||= item.tags
		options[:placeholder] ||= 'Add tag...'
		content_tag(:div, :class => 'tag_editor clearfix') do
			form_helper.hidden_field(field_name, :class => 'serialized_tags') +
			content_tag(:div, :class => :tags) do
				options[:tags].map do |tag|
					content_tag(:span, :class => :tag) do
						check_box_tag("tag-#{tag.id}", 1, options[:tagged].include?(tag)) +
						content_tag(:span, tag.name, :class => :name)
					end
				end.join
			end +
			content_tag(:div, :class => 'add_tag_form') do
				text_field_tag('add_tag', options[:placeholder], :class => 'add_tag') +
				content_tag(:button, 'Add', :class => 'add_tag_button')
			end
		end
	end

	# Generates tags for an editable dynamic image.
	def editable_dynamic_image_tag(image, options={})
		link_to(dynamic_image_tag(image, options), admin_image_path(image), :class => 'editableImage')
	end

	def admin_javascript_tags
		output  = "\t" + javascript_include_tag("admin/admin",       :plugin => 'pages') + "\n"
		output += "\t" + javascript_include_tag("admin/tag_editor",  :plugin => 'pages') + "\n"
		output += "\t" + javascript_include_tag("admin/page_images", :plugin => 'pages') + "\n"

		controller_name    = controller.class.to_s.demodulize
		action_name        = params[:action]
		controller_script = controller.class.to_s.underscore

		if File.exists?(PagesCore.plugin_root.join("app/assets/javascripts/#{controller_script}.js"))
			output += "\t"+javascript_include_tag(controller_script, :plugin => 'pages') + "\n"
		end
		output += "<script type=\"text/javascript\">"
		output += "  Admin.controller = Admin.#{controller_name};"
		output += "  Admin.action     = \"#{action_name}\";"
		output += "  Admin.language   = \"#{@language}\";" if @language
		output += "</script>"

		output.html_safe
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
	def labelled_field( field, label=nil, options={} )
		if options[:errors]
			output  = '<div class="field field_with_errors">'
		else
			output  = '<div class="field">'
		end
		output += "<label>#{label}" if label
		if options[:errors]
			error = options[:errors]
			error = error.last if error.kind_of? Array
			output += ' <span class="error">' + error + '</span>'
		end
		output += "</label>" if label
		output += "<p class=\"description\">#{options[:description]}</p>" if options[:description]
		output += field
		output += "#{options[:check_box_description]}" if options[:check_box_description]
		output += "</div>"
	end

	def image_upload_field( form, label, method=nil, options={} )
		method ||= :image
		output = ''
		if form.object.send(method)
			output += "<p>"+dynamic_image_tag( form.object.send(method), :size => '120x100' )+"</p>"
		end
		output += labelled_field(form.file_field(method), label, { :errors => form.object.errors[method] }.merge(options))
	end

	def body_classes
		classes = @body_classes || []
		classes << controller.class.underscore
		classes << "#{controller.action_name}_action"
		classes << "with_sidebar" if @sidebar_enabled
		classes << "with_notice" if flash[:notice]
		classes.reverse.join( " " )
	end

	def add_body_class( class_name )
		@body_classes ||= []
		@body_classes << class_name
	end

	def header_tabs( options={} )
		options = {
			:class => :pages
		}.merge(options)

		menu_items = @admin_menu.select{|i| i[:class] == options[:class]}

		# Determine current menu item
		current_tab = menu_items.select { |menu_item|
			if menu_item[:options] && menu_item[:options][:current]
				menu_item[:options][:current].call
			else
				menu_item[:url][:controller] == controller.class.controller_path
			end
		}.first

		# Build menu
		if menu_items.length > 0
			menu_items = menu_items.collect do |menu_item|
				classes = []
				begin
					controller_name = menu_item[:url][:controller]
				rescue
					controller_name = ""
					logger.warn "Cannot get controller name from #{menu_item.inspect}"
				end
				action_name = menu_item[:url][:action]

				classes << "current" if menu_item == current_tab

				link_to(menu_item[:name], menu_item[:url], :class => classes.join(' '))
			end
			"<ul class=\"#{options[:class]}\">" + menu_items.map{ |item| "<li>#{item}</li>" }.join() + "</ul>"
		else
			""
		end
	end

	def page_title( title )
		@page_title = title
	end

	def page_description( string, class_name=nil )
		@page_description = string
		@page_description_class = class_name
	end

	def page_description_links( links )
		@page_description_links = links
	end

	def sidebar( string="", &block )
		@sidebar = string
		if block_given?
			@sidebar += capture( &block )
		end
	end

	def content_tab( name, options={}, &block )
		@content_tabs ||= []
		if block_given?
			tab = {
				:name    => name.to_s.humanize,
				:key     => name.to_s.underscore.gsub(/[\s]+/, '_'),
				:options => options,
				:content => capture(&block)
			}
			@content_tabs << tab
			tab_output = "<div class=\"content_tab\" id=\"content-tab-#{tab[:key]}\">"
			tab_output += tab[:content]
			tab_output += "</div>"
			concat(tab_output)
		else
			#    tab = @content_tabs.select{ |t| t[:key] == name.to_s.underscore }.first
    		#    "<div class=\"content_tab\" id=\"content-tab-#{tab[:key]}\">#{tab[:content]}</div>"
    		""
		end
	end

	def pages_button_to(name, options = {}, html_options = {})
		html_options = html_options.stringify_keys
		convert_boolean_attributes!(html_options, %w( disabled ))

		method_tag = ''
		if (method = html_options.delete('method')) && %w{put delete}.include?(method.to_s)
			method_tag = tag('input', :type => 'hidden', :name => '_method', :value => method.to_s)
		end

		form_method = method.to_s == 'get' ? 'get' : 'post'

		if confirm = html_options.delete("confirm")
			html_options["onclick"] = "return #{confirm_javascript_function(confirm)};"
		end

		url = options.is_a?(String) ? options : self.url_for(options)
		name ||= url

		html_options.merge!( "type" => "submit" )

		"<form method=\"#{form_method}\" action=\"#{escape_once url}\" class=\"button-to\">" +
		method_tag + content_tag( "button", name, html_options ) + "</form>"
	end

	def link_separator
		' <span class="separator">|</span> '
	end

end
