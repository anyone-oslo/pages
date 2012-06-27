module Localizable

  class Configuration
    attr_reader :allow_any
    def attribute(attribute_name, options={})
      attributes[attribute_name.to_sym] = options
    end

    def attributes
      @attributes ||= {}
    end

    def has_attribute?(attribute)
      @attributes.keys.include?(attribute)
    end

    def allow_any(new_value=nil)
      @allow_any = new_value unless new_value.nil?
      @allow_any
    end

    def allow_any?
      allow_any ? true : false
    end
  end

end