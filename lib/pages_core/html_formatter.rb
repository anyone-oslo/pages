module PagesCore
  class HtmlFormatter

    class << self
      def to_html(string, options={})
        self.new(string, options).to_html
      end
    end

    def initialize(string, options={})
      @string = string
    end

    def to_html
      RedCloth.new(@string).to_html.html_safe
    end
  end
end