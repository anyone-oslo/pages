module Localizable

  module InstanceMethods
    def localizer
      @localizer ||= Localizer.new(self.class.localizable_configuration)
    end
  end

end
