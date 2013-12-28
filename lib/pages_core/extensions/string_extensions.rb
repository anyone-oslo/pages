# encoding: utf-8

module PagesCore
  module Extensions
    module StringExtensions

      def to_html_with(append, options={})
        self.to_html(options.merge(:append => append))
      end

      def to_html(options={})
        PagesCore::HtmlFormatter.to_html(self, options)
      end

      # Prepend http:// if necessary
      # DEPRECATED: Remove this in 2.5
      def with_http
        ActiveSupport::Deprecation.warn "String#with_http is deprecated"
        (self.strip =~ /^https?:\/\//) ? self.strip : "http://"+self.strip
      end

      # Strip http:// from the string
      # DEPRECATED: Remove this in 2.5
      def without_http
        ActiveSupport::Deprecation.warn "String#without_http is deprecated"
        self.strip.gsub(/^https?:\/\//, '')
      end

    end
  end
end

String.send(:include, PagesCore::Extensions::StringExtensions)
