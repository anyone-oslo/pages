# encoding: utf-8

module PagesCore
  module StringExtensions

    # Truncate string to max_length, retaining words. If the first word is shorter than max_length,
        # it will be shortened. An optional end_string can be supplied, which will be appended to the
        # string if it has been truncated.
      def truncate(max_length, end_string='')
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
    def with_http
      (self.strip =~ /^https?:\/\//) ? self.strip : "http://"+self.strip
    end

    # Strip http:// from the string
    def without_http
      self.strip.gsub(/^https?:\/\//, '')
    end

  end
end

String.send(:include, PagesCore::StringExtensions)
