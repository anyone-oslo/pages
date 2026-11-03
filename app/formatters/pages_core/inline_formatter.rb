# frozen_string_literal: true

require "RedCloth"

module PagesCore
  class InlineFormatter
    include ActionView::Helpers::SanitizeHelper

    class << self
      def to_html(string)
        new(string).to_html
      end
    end

    def initialize(string)
      @string = string
    end

    def to_html
      textile = RedCloth.new(ERB::Util.html_escape(@string),
                             %i[lite_mode filter_styles])
      sanitize(textile.to_html,
               tags: %w[strong em b i sup sub del ins span cite code br],
               attributes: []).gsub('"', "&quot;").html_safe
    end
  end
end
