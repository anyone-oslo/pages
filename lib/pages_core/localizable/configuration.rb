# encoding: utf-8

module PagesCore
  module Localizable
    class Configuration
      def initialize(attributes = nil)
        @attributes = attributes
      end

      def attribute(attribute_name, options = {})
        attribute_table[attribute_name.to_sym] = options
      end

      def attributes
        attribute_table.merge(dictionary_attributes)
      end

      def dictionary(dict)
        dictionaries << dict
      end

      def attribute?(attribute)
        attributes.keys.include?(attribute)
      end

      private

      def dictionaries
        @dictionaries ||= []
      end

      def dictionary_attributes
        dictionaries.map(&:call).inject({}) do |attrs, list|
          attrs.merge(hashify(list))
        end
      end

      def hashify(list)
        return list if list.is_a?(Hash)
        list.each_with_object({}) do |e, a|
          a[e] = {}
        end
      end

      def attribute_table
        @attributes ||= {}
      end
    end
  end
end
