# encoding: utf-8

module PagesCore
  module Localizable
    class Localizer
      attr_accessor :locale
      def initialize(model)
        @model         = model
        @configuration = model.class.localizable_configuration
      end

      def attribute?(attribute)
        @configuration.attribute?(attribute)
      end

      def locales
        @model.localizations.map(&:locale).uniq
      end

      def locale?
        locale ? true : false
      end

      def get(attribute, options = {})
        get_options = { locale: locale }.merge(options)

        find_localizations(
          attribute.to_s,
          get_options[:locale].to_s
        ).try(&:first) ||
          @model.localizations.new(
            locale: get_options[:locale].to_s,
            name: attribute.to_s
          )
      end

      def set(attribute, value, options = {})
        set_options = { locale: locale }.merge(options)
        if value.is_a?(Hash)
          value.each do |loc, val|
            set(attribute, val, locale: loc)
          end
        else
          unless set_options[:locale]
            fail(
              ArgumentError,
              "Tried to set :#{attribute}, but no locale has been set"
            )
          end
          get(attribute, locale: set_options[:locale]).value = value
        end
        value
      end

      def value_for?(attribute)
        get(attribute).value?
      end

      def cleanup_localizations!
        @model.localizations = @model.localizations.select(&:value?)
      end

      private

      def find_localizations(name, locale)
        @model.localizations.select do |l|
          l.name == name && l.locale == locale
        end
      end
    end
  end
end
