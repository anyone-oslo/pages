# encoding: utf-8

module PagesCore
  module Admin
    module AdminHelper
      include PagesCore::Admin::LabelledFieldHelper
      include PagesCore::Admin::TagEditorHelper

      attr_accessor :page_title
      attr_accessor :page_description
      attr_accessor :page_description_class
      attr_accessor :page_description_links

      def add_body_class(class_name)
        @body_classes ||= []
        @body_classes << class_name
      end

      def body_classes
        classes = @body_classes || []
        classes << controller.class.to_s.underscore
        classes << "#{controller.action_name}_action" if controller.action_name
        classes << "with_notice" if flash[:notice]
        classes
      end

      # Generates tags for an editable dynamic image.
      def editable_dynamic_image_tag(image, options = {})
        preview_url = uncropped_dynamic_image_url(image, size: "800x")
        link_to(
          dynamic_image_tag(image, options), admin_image_path(image),
          class: "editableImage",
          data: { "preview-url" => preview_url }
        )
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
        content_tab_tag(tab[:key], tab[:content])
      end

      def link_separator
        ' <span class="separator">|</span> '.html_safe
      end

      def deprecate_page_description_args(string = nil, class_name = nil)
        if class_name
          ActiveSupport::Deprecation.warn("Setting class through " \
                                          "page_description is deprecated, " \
                                          "use page_description_class=")
        end
        if string
          ActiveSupport::Deprecation.warn("Setting description with " \
                                          "page_description is deprecated, " \
                                          "use page_description=")
        end
      end

      def page_description(string = nil, class_name = nil)
        deprecate_page_description_args(string, class_name)
        @page_description_class = class_name if class_name
        if string
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

      private

      def content_tab_tag(key, content)
        content_tag(:div,
                    content,
                    class: "content_tab",
                    id: "content-tab-#{key}")
      end
    end
  end
end
