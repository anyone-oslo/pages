# encoding: utf-8

module PagesCore
  module Localizable

    # = Localizable::ClassMethods
    #
    # Class methods for all Localizable models.
    #
    module ClassMethods

      # Accessor for the configuration.
      def localizable_configuration
        @localizable_configuration ||= Localizable::Configuration.new
      end
    end
  end
end
