# frozen_string_literal: true

module PagesCore
  module Admin
    module ImageUploadsHelper
      # Generates tags for an editable dynamic image.
      def editable_dynamic_image_tag(image, width: 250,
                                     caption: false, locale: nil)
        react_component("EditableImage",
                        editable_image_options(
                          image,
                          width: width,
                          caption: caption,
                          locale: locale
                        ).merge(width: width))
      end

      def image_uploader_tag(name, image, options = {})
        opts = { caption: false, locale: nil }.merge(options)
        react_component("ImageUploader",
                        editable_image_options(
                          image,
                          caption: opts[:caption],
                          locale: opts[:locale]
                        ).merge(attr: name, alternative: opts[:alternative]))
      end

      private

      def editable_image_src_options(image, width)
        return {} unless image

        { src: dynamic_image_path(image, size: "#{width * 2}x"),
          image: ::Admin::ImageResource.new(image).to_hash }
      end

      def editable_image_options(image, width: 250, caption: false, locale: nil)
        editable_image_src_options(image, width).merge(
          width: width,
          caption: caption,
          locale: locale || I18n.default_locale,
          locales: PagesCore.config.locales
        )
      end
    end
  end
end
