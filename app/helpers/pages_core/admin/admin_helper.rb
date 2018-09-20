module PagesCore
  module Admin
    module AdminHelper
      include PagesCore::Admin::LabelledFieldHelper
      include PagesCore::Admin::TagEditorHelper

      attr_writer :page_title
      attr_writer :page_description
      attr_writer :page_description_class
      attr_writer :page_description_links

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

      def date_range(starts_at, ends_at)
        show_time = !(starts_at.is_a?(Date) && ends_at.is_a?(Date))
        dates = if starts_at.year != ends_at.year
                  [l(starts_at, format: :pages_full), l(ends_at, format: :pages_full)]
                elsif starts_at.month != ends_at.month
                  [l(starts_at, format: :pages_date), l(ends_at, format: :pages_full)]
                elsif starts_at.day != ends_at.day && !show_time
                  [l(starts_at, format: :pages_day), l(ends_at, format: :pages_full)]
                elsif starts_at.day != ends_at.day
                  [l(starts_at, format: :pages_date), l(ends_at, format: :pages_full)]
                elsif !show_time
                  [l(starts_at, format: :pages_full)]
                else
                  [l(starts_at, format: :pages_full), l(ends_at, format: :pages_time)]
                end
        safe_join(dates.map(&:strip), "&ndash;".html_safe)
      end

      # Generates tags for an editable dynamic image.
      def editable_dynamic_image_tag(image, width: 250, caption: false, locale: nil)
        react_component("EditableImage",
                        caption: caption,
                        src: dynamic_image_path(image, size: "#{width}x"),
                        width: width,
                        locale: locale || I18n.default_locale,
                        locales: PagesCore.config.locales,
                        csrf_token: form_authenticity_token,
                        image: ::Admin::ImageSerializer.new(image))
      end

      def content_tab(name, options = {}, &block)
        @content_tabs ||= []
        return unless block_given?
        tab = {
          name:    name.to_s.humanize,
          key:     options[:key] || name.to_s.underscore.gsub(/[\s]+/, "_"),
          options: options,
          content: capture(&block)
        }
        @content_tabs << tab
        content_tab_tag(tab[:key], tab[:content])
      end

      def link_separator
        safe_join [" ", content_tag(:span, "|", class: "separator"), " "]
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
