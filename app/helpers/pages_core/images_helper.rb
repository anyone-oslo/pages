# frozen_string_literal: true

module PagesCore
  module ImagesHelper
    include DynamicImage::Helper

    def dynamic_image_tag(record_or_array, options = {})
      super(record_or_array,
            extract_alt_text(record_or_array).merge(options))
    end

    def image_caption(image, caption: nil)
      return if caption == false

      caption = image.caption unless caption.is_a?(String)
      return if caption.blank?

      tag.figcaption(caption)
    end

    # Renders an image figure tag with caption.
    #
    # ==== Options
    # * <tt>:caption</tt>: Override caption with a string, or set to false to
    #   disable captions.
    # * <tt>:class_name</tt>: Class name to add to figure tag.
    # * <tt>:link</tt>: Link target for image.
    # * <tt>:ratio</tt>: Ratio to constrain image by.
    # * <tt>:size</tt>: Max size for image.
    def image_figure(image, opts = {})
      class_name = ["image", image_class_name(image), opts[:class_name]].compact
      image_tag = image_figure_image_tag(image,
                                         size: opts[:size],
                                         ratio: opts[:ratio])
      content = opts[:link] ? image_link_to(image_tag, opts[:link]) : image_tag
      tag.figure(content + image_caption(image, caption: opts[:caption]),
                 class: class_name)
    end

    # Renders an image figure tag with caption.
    #
    # ==== Options
    # * <tt>:caption</tt>: Override caption with a string, or set to false to
    #   disable captions.
    # * <tt>:class_name</tt>: Class name to add to figure tag.
    # * <tt>:link</tt>: Link target for image.
    # * <tt>:ratio</tt>: Ratio to constrain image by.
    # * <tt>:sizes</tt>: Sizes attribute for image tag, default: "100vw".
    def picture(image, opts = {})
      class_name = ["image", image_class_name(image), opts[:class_name]].compact
      pict = picture_tag(image, ratio: opts[:ratio], sizes: opts[:sizes])
      content = opts[:link] ? image_link_to(pict, opts[:link]) : pict
      tag.figure(content + image_caption(image, caption: opts[:caption]),
                 class: class_name)
    end

    def picture_tag(image, ratio: nil, sizes: "100vw")
      tag.picture do
        safe_join(
          [webp_source(image, ratio: ratio, sizes: sizes || "100vw"),
           dynamic_image_tag(image,
                             size: image_size(1050, ratio),
                             crop: (ratio ? true : false),
                             sizes: sizes,
                             srcset: srcset(image, ratio: ratio))]
        )
      end
    end

    def original_dynamic_image_tag(record_or_array, options = {})
      super(record_or_array,
            extract_alt_text(record_or_array).merge(options))
    end

    def uncropped_dynamic_image_tag(record_or_array, options = {})
      super(record_or_array,
            extract_alt_text(record_or_array).merge(options))
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

    def fit_ratio(size, ratio)
      v = Vector2d(size)
      Vector2d.new(v.y * ratio, v.y).fit(v)
    end

    def image_class_name(image)
      return "square" if image.size.x == image.size.y
      return "landscape" if image.size.x > image.size.y

      "portrait"
    end

    def image_figure_image_tag(image, size: nil, ratio: nil)
      size ||= default_image_size
      size = fit_ratio(size, ratio) if ratio

      dynamic_image_tag(image, size: size, crop: ratio && true, upscale: false)
    end

    def image_link_to(content, href)
      tag.a(content, href: href)
    end

    def image_size(width, ratio)
      return "#{width}x" unless ratio

      "#{width}x#{(width / ratio).round}"
    end

    def image_widths(image)
      [233, 350, 700, 1050, 1400, 2100, 2800].select do |w|
        image.size.x >= w
      end
    end

    def srcset(image, ratio: nil, format: nil)
      image_widths(image).map do |width|
        options = { size: image_size(width, ratio),
                    crop: (ratio ? true : false) }
        options[:format] = format if format

        "#{dynamic_image_path(image, options)} #{width}w"
      end.join(", ")
    end

    def webp_source(image, ratio: nil, sizes: "100vw")
      return unless webp_compatible?(image)

      tag.source(type: "image/webp",
                 srcset: srcset(image, ratio: ratio, format: :webp),
                 sizes: sizes)
    end

    def webp_compatible?(image)
      image.content_type != "image/gif"
    end
  end
end
