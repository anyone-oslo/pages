# frozen_string_literal: true

module PagesCore
  class CacheSweeper
    class << self
      attr_accessor :enabled

      def disable(&)
        old_value = enabled
        self.enabled = false
        yield if block_given?
        self.enabled = old_value
      end

      def once(&)
        disable(&)
        PagesCore::StaticCache.handler.sweep!
      end
    end

    self.enabled ||= true
  end
end
