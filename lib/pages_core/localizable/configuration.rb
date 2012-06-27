module Localizable

  class Configuration
    def attribute(attribute_name, options={})
      attributes[attribute_name.to_sym] = options
    end

    def attributes
      @attributes ||= {}
    end

    def has_attribute?(attribute)
      @attributes.keys.include?(attribute)
    end
  end

end