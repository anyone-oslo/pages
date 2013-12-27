# encoding: utf-8

module PagesCore
  module Localizable

    # = Localizable::ClassMethods
    #
    # Class methods for all Localizable models.
    #
    module ClassMethods

      # Returns a scope where all records will be set to the given locale.
      #
      def in_locale(locale)
        scoped.extending(Localizable::ScopeExtension).localize(locale).includes(:localizations)
      end

      # Returns a scope with only records matching the given locale.
      #
      #  Page.localized('en').first.locale # => 'en'
      #
      def localized(locale)
        in_locale(locale).where('localizations.locale = ?', locale)
      end

      def localized_attributes
        localizable_configuration.attributes.keys
      end

      # Accessor for the configuration.
      def localizable_configuration
        @localizable_configuration ||= Localizable::Configuration.new
      end
    end
  end
end
