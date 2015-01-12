# encoding: utf-8

module PagesCore
  module Localizable

    class Configuration
      def initialize(attributes=nil)
        @attributes = attributes
      end

      def attribute(attribute_name, options={})
        attribute_table[attribute_name.to_sym] = options
      end

      def attributes
        attribute_table.merge(dictionary_attributes)
      end

      def dictionary(dict)
        dictionaries << dict
      end

      def has_attribute?(attribute)
        attributes.keys.include?(attribute)
      end

      private

      def dictionaries
        @dictionaries ||= []
      end

      def dictionary_attributes
        dictionaries.map{ |l| l.call }.inject({}) do |attrs, list|
          attrs.merge(hashify(list))
        end
      end

      def hashify(list)
        return list if list.kind_of?(Hash)
        list.inject({}) { |h, k| h[k] = {}; h }
      end

      def attribute_table
        @attributes ||= {}
      end
    end
  end
end
