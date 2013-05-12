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

      # Truncate string to max_length, retaining words. If the first word is shorter than max_length,
      # it will be shortened. An optional end_string can be supplied, which will be appended to the
      # string if it has been truncated.
      # DEPRECATED: Remove this in 2.5
      def truncate(max_length, end_string='')
        ActiveSupport::Deprecation.warn "String#truncate is deprecated"
        words = self.split(' ')
        new_words = [words.shift]
        while words.length > 0 && (new_words.join(' ').length + words.first.length) < max_length
            new_words << words.shift
          end
          new_string = new_words.join(' ')
          new_string = new_string[0...max_length] if new_string.length > max_length
          new_string += end_string unless new_string == self
          return new_string
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
