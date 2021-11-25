# frozen_string_literal: true

module PagesCore
  class CacheSweeper
    class << self
      attr_accessor :enabled

      def disable(&_block)
        old_value = enabled
        self.enabled = false
        yield if block_given?
        self.enabled = old_value
      end

      def once(&block)
        disable(&block)
        PagesCore::StaticCache.handler.sweep!
      end
    end

    self.enabled ||= true
  end
end
