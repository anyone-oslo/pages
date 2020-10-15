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

      def config(&block)
        ActiveSupport::Deprecation.warn(
          "PagesCore::CacheSweeper.config is deprecated, use " \
          "PagesCore::StaticCache::PageCacheHandler.config"
        )
        PagesCore::StaticCache::PageCacheHandler.config(&block)
      end
    end

    self.enabled ||= true
  end
end
