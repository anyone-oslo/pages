# frozen_string_literal: true

module PagesCore
  class CacheSweeper
    class << self
      attr_accessor :enabled

      def disable(&_block)
        old_value = enabled
        self.enabled = false
        yield
        self.enabled = old_value
      end

      def once(&block)
        disable(&block)
        PagesCore::StaticCache.handler.sweep!
      end

      def config
        ActiveSupport::Deprecation.warn(
          "PagesCore::CacheSweeper.config is no longer used."
        )
        configuration = OpenStruct.new(patterns: [])
        yield configuration if block_given?
        configuration
      end
    end

    self.enabled ||= true
  end
end
