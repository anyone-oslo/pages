# encoding: utf-8

module PagesCore
  module Localizable
    # = Localizable::ActiveRecordExtension
    #
    # Extends ActiveRecord::Base with the localizable setup method.
    #
    module ActiveRecordExtension
      # Extends the model with Localizable features.
      # It takes an optional block as argument, which yields an instance of
      # Localizable::Configuration.
      #
      # Example:
      #
      #  class Page < ActiveRecord::Base
      #    localizable do
      #      attribute :name
      #      attribute :body
      #    end
      #  end
      #
      def localizable(&block)
        unless is_a?(Localizable::ClassMethods)
          send :extend,  Localizable::ClassMethods
          send :include, Localizable::InstanceMethods
          has_many(:localizations,
                   as: :localizable,
                   dependent: :destroy,
                   autosave: true)
          before_save :cleanup_localizations!
        end
        localizable_configuration.instance_eval(&block) if block_given?
      end
    end
  end
end

ActiveRecord::Base.send(:extend, PagesCore::Localizable::ActiveRecordExtension)
