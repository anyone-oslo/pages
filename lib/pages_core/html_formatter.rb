# encoding: utf-8

module PagesCore
  class HtmlFormatter

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
      string = @string
      if @options[:shorten] && string.length > @options[:shorten]
        string = string[0..@options[:shorten]] + "..."
      end
      if @options[:append]
        string += " #{@options[:append]}"
      end
      RedCloth.new(string).to_html.html_safe
    end
  end
end