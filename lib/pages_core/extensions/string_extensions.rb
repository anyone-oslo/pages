# frozen_string_literal: true

module PagesCore
  module Extensions
    module StringExtensions
      def to_html_with(append, options = {})
        to_html(options.merge(append: append))
      end

      def to_html(options = {})
        PagesCore::HtmlFormatter.to_html(self, options)
      end
    end
  end
end

String.include PagesCore::Extensions::StringExtensions
