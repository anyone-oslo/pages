# encoding: utf-8

module PagesCore
  module Admin
    module AdminHelper
      def tag_editor_for(form_helper, item, field_name = :serialized_tags, options = {})
        options[:tags]        ||= Tag.tags_and_suggestions_for(item, limit: 20)
        options[:tagged]      ||= item.tags
        options[:placeholder] ||= 'Add tag...'
        content_tag(:div, class: 'tag_editor clearfix') do
          form_helper.hidden_field(field_name, class: 'serialized_tags') +
          content_tag(:div, class: :tags) do
            options[:tags].map do |tag|
              content_tag(:span, class: :tag) do
                check_box_tag("tag-#{tag.id}", 1, options[:tagged].include?(tag)) +
                content_tag(:span, tag.name, class: :name)
              end
            end.join.html_safe
          end +
          content_tag(:div, class: 'add_tag_form') do
            text_field_tag('add_tag', options[:placeholder], class: 'add_tag') +
            content_tag(:button, 'Add', class: 'add_tag_button')
          end
        end
      end

      # Generates tags for an editable dynamic image.
      def editable_dynamic_image_tag(image, options={})
        preview_url = uncropped_dynamic_image_url(image, size: '800x')
        link_to(
          dynamic_image_tag(image, options), admin_image_path(image),
          class: 'editableImage',
          data: { 'preview-url' => preview_url }
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
      #                        description: "Choose your username, minimum 4 characters",
      #                        errors: @user.errors[:username] %>
      #     <%= submit_tag "Save" %>
      #   <% end %>
      #
      def labelled_field( field, label=nil, options={} )
        if options[:errors] && options[:errors].any?
          output  = '<div class="field field_with_errors">'
        else
          output  = '<div class="field">'
        end
        output += "<label>#{label}" if label
        if options[:errors] && options[:errors].any?
          error = options[:errors]
          error = error.last if error.kind_of? Array
          output += ' <span class="error">' + error + '</span>'
        end
        output += "</label>" if label
        output += "<p class=\"description\">#{options[:description]}</p>" if options[:description]
        output += field
        output += "#{options[:check_box_description]}" if options[:check_box_description]
        output += "</div>"
        output.html_safe
      end

      def image_upload_field( form, label, method=nil, options={} )
        method ||= :image
        output = ''
        if form.object.send(method)
          output += "<p>"+dynamic_image_tag( form.object.send(method), size: '120x100' )+"</p>"
        end
        output += labelled_field(form.file_field(method), label, { errors: form.object.errors[method] }.merge(options))
        output.html_safe
      end

      def body_classes
        classes = @body_classes || []
        classes << controller.class.underscore
        classes << "#{controller.action_name}_action"
        classes << "with_sidebar" if content_for?(:sidebar)
        classes << "with_notice" if flash[:notice]
        classes.reverse.join( " " )
      end

      def add_body_class( class_name )
        @body_classes ||= []
        @body_classes << class_name
      end

      def page_title(title)
        @page_title = title
      end

      def page_description(string, class_name=nil)
        @page_description = string
        @page_description_class = class_name
      end

      def page_description_links(links)
        @page_description_links = links
      end

      def sidebar( string="", &block )
        @sidebar = string
        if block_given?
          @sidebar += capture( &block )
        end
      end

      def content_tab(name, options={}, &block)
        @content_tabs ||= []
        if block_given?
          tab = {
            name:    name.to_s.humanize,
            key:     name.to_s.underscore.gsub(/[\s]+/, '_'),
            options: options,
            content: capture(&block)
          }
          @content_tabs << tab
          tab_output = "<div class=\"content_tab\" id=\"content-tab-#{tab[:key]}\">"
          tab_output += tab[:content]
          tab_output += "</div>"
          tab_output.html_safe
        else
          #    tab = @content_tabs.select{ |t| t[:key] == name.to_s.underscore }.first
            #    "<div class=\"content_tab\" id=\"content-tab-#{tab[:key]}\">#{tab[:content]}</div>"
            ""
        end
      end

      def link_separator
        ' <span class="separator">|</span> '.html_safe
      end
    end
  end
end
