# encoding: utf-8

module PagesCore
  module Admin
    module AdminHelper
      include PagesCore::Admin::LabelledFieldHelper
      include PagesCore::Admin::TagEditorHelper

      # Generates tags for an editable dynamic image.
      def editable_dynamic_image_tag(image, options = {})
        preview_url = uncropped_dynamic_image_url(image, size: "800x")
        link_to(
          dynamic_image_tag(image, options), admin_image_path(image),
          class: "editableImage",
          data: { "preview-url" => preview_url }
        )
      end

      def body_classes
        classes = @body_classes || []
        classes << controller.class.underscore
        classes << "#{controller.action_name}_action"
        classes << "with-sidebar" if content_for?(:sidebar)
        classes << "with_notice" if flash[:notice]
        classes.reverse.join(" ")
      end

      def add_body_class(class_name)
        @body_classes ||= []
        @body_classes << class_name
      end

      attr_accessor :page_title
      attr_accessor :page_description
      attr_accessor :page_description_class
      attr_accessor :page_description_links

      def page_title(title = nil)
        if title
          ActiveSupport::Deprecation.warn(
            "Setting page title with page_title is deprecated, use page_title="
          )
          @page_title = title
        else
          @page_title
        end
      end

      def page_description(string = nil, class_name = nil)
        if class_name
          ActiveSupport::Deprecation.warn(
            "Setting page description class through page_description " \
              "is deprecated, use page_description_class="
          )
          @page_description_class = class_name
        end
        if string
          ActiveSupport::Deprecation.warn(
            "Setting description with page_description is deprecated, " \
              "use page_description="
          )
          @page_description = string
        else
          @page_description
        end
      end

      def page_description_links(links = nil)
        if links
          ActiveSupport::Deprecation.warn(
            "Setting page description_links with page_description_links " \
              "is deprecated, use page_description_links="
          )
          @page_description_links = links
        else
          @page_description_links
        end
      end

      def sidebar(string = "", &block)
        @sidebar = string
        return unless block_given?
        @sidebar += capture(&block)
      end

      def content_tab(name, options = {}, &block)
        @content_tabs ||= []
        return unless block_given?
        tab = {
          name:    name.to_s.humanize,
          key:     name.to_s.underscore.gsub(/[\s]+/, "_"),
          options: options,
          content: capture(&block)
        }
        @content_tabs << tab
        tab_output = "<div class=\"content_tab\" " \
          "id=\"content-tab-#{tab[:key]}\">"
        tab_output += tab[:content]
        tab_output += "</div>"
        tab_output.html_safe
      end

      def link_separator
        ' <span class="separator">|</span> '.html_safe
      end
    end
  end
end
