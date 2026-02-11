# frozen_string_literal: true

module PagesCore
  class HtmlFormatter
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
      string = shorten(parse_images(parse_files(parse_attachments(@string))))
      string += " #{@options[:append]}" if @options[:append]
      fix_markup(RedCloth.new(string).to_html).html_safe
    end

    private

    def attachment_expression
      /\[attachment:([\d,]+)\]/
    end

    def file_expression
      /\[file:([\d,]+)\]/
    end

    def find_attachment(id)
      Attachment.find(id).localize(I18n.locale)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def find_attachments(str)
      str.match(attachment_expression)[1]
         .split(",")
         .filter_map { |id| find_attachment(id) }
    end

    def find_file(id)
      PageFile.find(id).localize(I18n.locale)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def find_files(str)
      str.match(file_expression)[1]
         .split(",")
         .filter_map { |id| find_file(id) }
    end

    def fix_markup(str)
      Nokogiri::HTML.fragment(str).to_html
    end

    def parse_attachments(string)
      string.gsub(attachment_expression).each do |str|
        PagesCore.config.attachment_embedder.new(
          find_attachments(str)
        ).to_html
      end
    end

    def parse_files(string)
      string.gsub(file_expression).each do |str|
        PagesCore.config.attachment_embedder.new(
          find_files(str).map(&:attachment)
        ).to_html
      end
    end

    def parse_images(string)
      PagesCore::ImageEmbedder.new(string).embed
    end

    def shorten(string)
      return string unless @options[:shorten] && string.length > @options[:shorten]

      "#{string[0..@options[:shorten]]}..."
    end
  end
end
