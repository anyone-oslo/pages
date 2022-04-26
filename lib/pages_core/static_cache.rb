# frozen_string_literal: true

require "pages_core/static_cache/null_handler"
require "pages_core/static_cache/page_cache_handler"
require "pages_core/static_cache/varnish_handler"

module PagesCore
  module StaticCache
    class << self
      def handler
        PagesCore.config.static_cache_handler || default_handler
      end

      private

      def default_handler
        return varnish_handler if ENV["VARNISH_URL"]

        # PagesCore::StaticCache::NullHandler.new
        PagesCore::StaticCache::PageCacheHandler.new
      end

      def varnish_handler
        PagesCore::StaticCache::VarnishHandler.new(
          ENV.fetch("VARNISH_URL", nil)
        )
      end
    end
  end
end
