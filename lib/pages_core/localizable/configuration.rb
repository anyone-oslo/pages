# encoding: utf-8

module PagesCore
  module Localizable

    class Configuration
      def initialize(attributes=nil)
        @attributes = attributes
      end

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
end
