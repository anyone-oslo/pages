module Localizable

  class Localizer
    attr_accessor :locale
    def initialize(configuration)
      @configuration = configuration
    end
  end

end