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
      image_figure(
        Image.find(id).localize(I18n.locale),
        size:, class_name:, link:
      )
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def embed_image_size(str)
      if str =~ /size="(\d*x\d*)"/
        Regexp.last_match(1)
      else
        default_image_size
      end
    end

    def parse_image(str)
      id = str.match(image_expression)[1]
      options = str.match(image_expression)[2]
      class_name = (Regexp.last_match(1) if options =~ /class="([\s\-\w]+)"/)
      link = (Regexp.last_match(1) if options =~ /link="([^"]+)"/)
      embed_image(id,
                  size: embed_image_size(options),
                  class_name:,
                  link:)
    end

    def parse_images(string)
      string.gsub(image_expression).each do |str|
        parse_image(str)
      end
    end
  end
end
