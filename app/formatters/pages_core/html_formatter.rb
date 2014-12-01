# encoding: utf-8

module PagesCore
  class HtmlFormatter
    include ActionView::Helpers::AssetTagHelper
    include DynamicImage::Helper
    include Rails.application.routes.url_helpers

    class << self
      def to_html(string, options={})
        self.new(string, options).to_html
      end
    end

    def initialize(string, options={})
      @string = string
      @options = options
    end

    def to_html
      string = parse_images(@string)
      if @options[:shorten] && string.length > @options[:shorten]
        string = string[0..@options[:shorten]] + "..."
      end
      if @options[:append]
        string += " #{@options[:append]}"
      end
      RedCloth.new(string).to_html.html_safe
    end

    private

    def parse_images(string)
      image_expression = /\[image:(\d+)([\s="\-_\w\d]*)?\]/
      string.gsub(image_expression).each do |str|
        id = str.match(image_expression)[1]
        options = str.match(image_expression)[2]

        size       = options.match(/size="(\d*x\d*)"/) ? $1 : "2000x2000"
        class_name = options.match(/class="([\s\-_\w\d]+)"/) ? $1 : nil

        begin
          image = Image.find(id)
          class_name = ['image', image_class_name(image), class_name].compact
          content_tag(:figure,
            dynamic_image_tag(image,
                              size: size,
                              crop: false,
                              upscale: false) +
              image_caption(image),
            class: class_name
          )
        rescue ActiveRecord::RecordNotFound
          nil
        end
      end
    end

    def image_caption(image)
      if image.byline?
        content_tag(:figcaption, image.byline)
      end
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
  end
end
