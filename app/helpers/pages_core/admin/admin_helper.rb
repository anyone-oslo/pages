# frozen_string_literal: true

module PagesCore
  module Admin
    module AdminHelper
      include PagesCore::Admin::ContentTabsHelper
      include PagesCore::Admin::DateRangeHelper
      include PagesCore::Admin::ImageUploadsHelper
      include PagesCore::Admin::LocalesHelper
      include PagesCore::Admin::LabelledFieldHelper
      include PagesCore::Admin::TagEditorHelper

      def rich_text_area_tag(name, content = nil, options = {})
        react_component("RichTextArea",
                        options.merge(id: sanitize_to_id(name),
                                      name:,
                                      value: content))
      end

      def locale_links
        return unless PagesCore.config.localizations?

        safe_join(
          PagesCore.config.locales.map do |locale, name|
            link_to(name, yield(locale),
                    class: ("current" if locale == params[:locale].to_sym))
          end
        )
      end

      def month_name(month)
        %w[January February March April May June July August September October
           November December][month - 1]
      end

      def qr_code(url)
        ActiveSupport::SafeBuffer.new(
          RQRCode::QRCode.new(url)
                         .as_svg({ color: "000",
                                   shape_rendering: "crispEdges",
                                   module_size: 10,
                                   use_path: true,
                                   viewbox: true })
        )
      end
    end
  end
end
