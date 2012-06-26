module Localizable
  module ClassMethods
    def localizable_configuration
      @localizable_configuration ||= Localizable::Configuration.new
    end
  end
end