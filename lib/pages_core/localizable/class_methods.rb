# encoding: utf-8

module PagesCore
  module Localizable

    # = Localizable::ClassMethods
    #
    # Class methods for all Localizable models.
    #
    module ClassMethods

      # Returns a scope with only records matching the given locale.
      #
      #  Page.localized('en').first.locale # => 'en'
      #
      def localized(locale)
        scoped.extending(Localizable::ScopeExtension)
          .localize(locale)
          .includes(:localizations)
          .where('localizations.locale = ?', locale)
      end

      # Accessor for the configuration.
      def localizable_configuration
        @localizable_configuration ||= Localizable::Configuration.new
      end
    end
  end
end
