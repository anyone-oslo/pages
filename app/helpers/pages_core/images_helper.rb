# frozen_string_literal: true

module PagesCore
  module ImagesHelper
    include DynamicImage::Helper

    def dynamic_image_tag(record_or_array, options = {})
      super(
        record_or_array,
        extract_alt_text(record_or_array).merge(options)
      )
    end

    def image_caption(image, caption: nil)
      return if caption == false

      caption = image.caption unless caption.is_a?(String)
      return if caption.blank?

      tag.figcaption(caption)
    end

    def image_figure(image, size: nil, class_name: nil, link: nil, caption: nil)
      class_name = ["image", image_class_name(image), class_name].compact
      size ||= default_image_size
      image_tag = dynamic_image_tag(image,
                                    size: size, crop: false, upscale: false)
      tag.figure((link ? image_link_to(image_tag, link) : image_tag) +
                 image_caption(image, caption: caption),
                 class: class_name)
    end

    def original_dynamic_image_tag(record_or_array, options = {})
      super(
        record_or_array,
        extract_alt_text(record_or_array).merge(options)
      )
    end

    def uncropped_dynamic_image_tag(record_or_array, options = {})
      super(
        record_or_array,
        extract_alt_text(record_or_array).merge(options)
      )
    end

    private

    def default_image_size
      "2000x2000"
    end

    def extract_alt_text(record_or_array)
      record = extract_dynamic_image_record(record_or_array)
      return {} unless record.alternative?

      { alt: record.alternative }
    end

    def image_class_name(image)
      if image.size.x == image.size.y
        "square"
      elsif image.size.x > image.size.y
        "landscape"
      else
        "portrait"
      end
    end

    def image_link_to(content, href)
      tag.a(content, href: href)
    end
  end
end
