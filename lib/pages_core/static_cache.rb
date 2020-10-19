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
        if ENV["VARNISH_URL"]
          return PagesCore::StaticCache::VarnishHandler.new(ENV["VARNISH_URL"])
        end

        # PagesCore::StaticCache::NullHandler.new
        PagesCore::StaticCache::PageCacheHandler.new
      end
    end
  end
end
