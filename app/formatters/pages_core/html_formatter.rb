module PagesCore
  class HtmlFormatter
    include ActionView::Helpers::AssetTagHelper
    include PagesCore::ImagesHelper
    include Rails.application.routes.url_helpers

    class << self
      def to_html(string, options = {})
        new(string, options).to_html
      end
    end

    def initialize(string, options = {})
      @string = string
      @options = options
    end

    def to_html
      string = parse_images(parse_files(@string))
      if @options[:shorten] && string.length > @options[:shorten]
        string = string[0..@options[:shorten]] + "..."
      end
      string += " #{@options[:append]}" if @options[:append]
      RedCloth.new(string).to_html.html_safe
    end

    private

    def file_expression
      /\[file:([\d,]+)\]/
    end

    def image_expression
      /\[image:(\d+)([^\]]*)?\]/
    end

    def embed_image(id, size:, class_name:, link:)
      image = Image.find(id).localize(I18n.locale)
      class_name = ["image", image_class_name(image), class_name].compact
      image_tag = dynamic_image_tag(image,
                                    size: size, crop: false, upscale: false)
      content_tag(:figure,
                  (link ? link_to(image_tag, link) : image_tag) +
                  image_caption(image),
                  class: class_name)
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

    def find_file(id)
      PageFile.find(id).localize(I18n.locale)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def find_files(str)
      str.match(file_expression)[1]
         .split(",")
         .map { |id| find_file(id) }
         .compact
    end

    def parse_files(string)
      string.gsub(file_expression).each do |str|
        PagesCore.config.file_embedder.new(find_files(str)).to_html
      end
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

    def image_caption(image)
      return unless image.caption?
      content_tag(:figcaption, image.caption)
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
      content_tag(:a, content, href: href)
    end
  end
end
