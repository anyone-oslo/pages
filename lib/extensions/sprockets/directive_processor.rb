# Workaround for MumboJumbo overriding [] on String,
# remove when MumboJumbo has been purged.
module Sprockets
  class DirectiveProcessor < Tilt::Template
    def prepare
      @pathname = Pathname.new(file)

      # Was:
      #@header = data[HEADER_PATTERN, 0] || ""

      # Workaround
      if match = data.match(HEADER_PATTERN)
        @header = match[0]
      else
        @header = ""
      end

      @body   = $' || data

      # Ensure body ends in a new line
      @body  += "\n" if @body != "" && @body !~ /\n\Z/m

      @included_pathnames = []
      @compat             = false
    end
  end
end
