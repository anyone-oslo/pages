# encoding: utf-8

module PagesCore
  module Localizable

    class Localizer
      attr_accessor :locale
      def initialize(model)
        @model         = model
        @configuration = model.class.localizable_configuration
      end

      def has_attribute?(attribute)
        @configuration.has_attribute?(attribute)
      end

      def locales
        @model.localizations.map(&:locale).uniq
      end

      def locale?
        locale ? true : false
      end

      def get(attribute, options={})
        get_options = {:locale => locale}.merge(options)
        localizations = @model.localizations.select{|l| l.name == attribute.to_s && l.locale == get_options[:locale].to_s}
        if localizations.length > 0
          localizations.first
        else
          localization = @model.localizations.new(:locale => get_options[:locale].to_s, :name => attribute.to_s)
          @model.localizations << localization
          localization
        end
      end

      def set(attribute, value, options={})
        set_options = {:locale => locale}.merge(options)
        if value.is_a?(Hash)
          value.each do |loc, val|
            set(attribute, val, :locale => loc)
          end
        else
          unless set_options[:locale]
            raise ArgumentError, "Tried to set :#{attribute}, but no locale has been set"
          end
          get(attribute, :locale => set_options[:locale]).value = value
        end
        value
      end

      def has_value_for?(attribute)
        get(attribute).value?
      end

      def cleanup_localizations!
        @model.localizations = @model.localizations.select{|l| l.value?}
      end
    end
  end
end
