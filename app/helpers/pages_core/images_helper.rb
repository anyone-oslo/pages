# frozen_string_literal: true

module PagesCore
  module ImagesHelper
    include DynamicImage::Helper

    def image_caption(image, caption: nil)
      return if caption == false

      caption = image.caption unless caption.is_a?(String)
      return if caption.blank?

      tag.figcaption(caption)
    end

    # Returns the orientation of an image as a class name.
    #
    # ==== Options
    # * <tt>:ratio</tt>: Ratio the image is constrained by.
    def image_class_name(image, ratio: nil)
      size = ratio ? fit_ratio(image.size, ratio) : image.size

      return "square" if size.x == size.y
      return "landscape" if size.x > size.y

      "portrait"
    end

    # Renders a responsive image in a figure tag with caption.
    #
    # ==== Options
    # * <tt>:caption</tt>: Override caption with a string, or set to false to
    #   disable captions.
    # * <tt>:class_name</tt>: Class name to add to figure tag.
    # * <tt>:link</tt>: Link target for image.
    # * <tt>:ratio</tt>: Ratio to constrain image by.
    # * <tt>:sizes</tt>: Sizes attribute for the image, default: "100vw".
    def image_figure(image, opts = {})
      opts = opts.symbolize_keys
      picture = dynamic_picture_tag(image, opts.slice(:ratio, :sizes))
      content = opts[:link] ? image_link_to(picture, opts[:link]) : picture

      tag.figure(content + image_caption(image, caption: opts[:caption]),
                 class: ["image",
                         image_class_name(image, ratio: opts[:ratio]),
                         opts[:class_name]].compact)
    end

    def picture(image, opts = {})
      PagesCore.deprecator.warn(
        "PagesCore::ImagesHelper#picture is deprecated, use #image_figure"
      )
      image_figure(image, opts)
    end

    private

    def fit_ratio(size, ratio)
      v = Vector2d(size)
      Vector2d.new(v.y * ratio, v.y).fit(v)
    end

    def image_link_to(content, href)
      tag.a(content, href:)
    end

    def image_size(width, ratio)
      return "#{width}x" unless ratio

      "#{width}x#{(width / ratio).round}"
    end

    def image_widths(image)
      [233, 350, 700, 1050, 1400, 2100, 2800].select { |w| image.size.x >= w }
    end

    def srcset(image, ratio: nil, format: nil)
      image_widths(image).map do |width|
        options = { size: image_size(width, ratio),
                    crop: (ratio ? true : false) }
        options[:format] = format if format

        "#{dynamic_image_path(image, options)} #{width}w"
      end.join(", ")
    end

    def webp_compatible?(image)
      image.content_type != "image/gif"
    end
  end
end
