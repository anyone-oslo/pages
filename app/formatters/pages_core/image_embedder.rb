# frozen_string_literal: true

module PagesCore
  class ImageEmbedder
    include ActionView::Helpers::AssetTagHelper
    include PagesCore::ImagesHelper
    include Rails.application.routes.url_helpers

    def initialize(string)
      @string = string
    end

    def embed
      parse_images(@string)
    end

    private

    def image_expression
      /\[image:(\d+)([^\]]*)?\]/
    end

    def embed_image(id, size:, class_name:, link:)
      image = Image.find(id).localize(I18n.locale)
      class_name = ["image", image_class_name(image), class_name].compact
      image_tag = dynamic_image_tag(image,
                                    size: size, crop: false, upscale: false)
      tag.figure((link ? link_to(image_tag, link) : image_tag) +
                  image_caption(image), class: class_name)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def embed_image_size(str)
      if str =~ /size="(\d*x\d*)"/
        Regexp.last_match(1)
      else
        "2000x2000"
      end
    end

    def image_caption(image)
      return unless image.caption?

      tag.figcaption(image.caption)
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

    def link_to(content, href)
      tag.a(content, href: href)
    end

    def parse_image(str)
      id = str.match(image_expression)[1]
      options = str.match(image_expression)[2]
      class_name = (Regexp.last_match(1) if options =~ /class="([\s\-\w]+)"/)
      link = (Regexp.last_match(1) if options =~ /link="([^"]+)"/)
      embed_image(id,
                  size: embed_image_size(options),
                  class_name: class_name,
                  link: link)
    end

    def parse_images(string)
      string.gsub(image_expression).each do |str|
        parse_image(str)
      end
    end
  end
end
