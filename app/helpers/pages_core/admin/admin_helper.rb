# frozen_string_literal: true

module PagesCore
  module Admin
    module AdminHelper
      include PagesCore::Admin::ContentTabsHelper
      include PagesCore::Admin::DateRangeHelper
      include PagesCore::Admin::ImageUploadsHelper
      include PagesCore::Admin::LocalesHelper
      include PagesCore::Admin::PageJsonHelper
      include PagesCore::Admin::LabelledFieldHelper
      include PagesCore::Admin::TagEditorHelper

      attr_writer :page_title, :page_description, :page_description_class,
                  :page_description_links

      def add_body_class(class_name)
        @body_classes ||= []
        @body_classes << class_name
      end

      def body_classes
        classes = @body_classes || []
        classes << "with_notice" if flash[:notice]
        classes
      end

      def rich_text_area_tag(name, content = nil, options = {})
        react_component("RichTextArea",
                        options.merge(id: sanitize_to_id(name),
                                      name: name,
                                      value: content))
      end

      def link_separator
        safe_join [" ", tag.span("|", class: "separator"), " "]
      end

      def deprecate_page_description_args(string = nil, class_name = nil)
        if class_name
          ActiveSupport::Deprecation.warn("Setting class through " \
                                          "page_description is deprecated, " \
                                          "use page_description_class=")
        end
        return unless string

        ActiveSupport::Deprecation.warn("Setting description with " \
                                        "page_description is deprecated, " \
                                        "use page_description=")
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
        return @page_description_links unless links

        ActiveSupport::Deprecation.warn(
          "Setting page description_links with page_description_links " \
          "is deprecated, use page_description_links="
        )
        @page_description_links = links
      end

      def page_title(title = nil)
        return @page_title unless title

        ActiveSupport::Deprecation.warn(
          "Setting page title with page_title is deprecated, use page_title="
        )
        @page_title = title
      end
    end
  end
end
