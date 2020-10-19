# frozen_string_literal: true

require "pages_core/static_cache/null_handler"
require "pages_core/static_cache/page_cache_handler"
require "pages_core/static_cache/varnish_handler"

module PagesCore
  module StaticCache
    class << self
      def handler
        PagesCore.config.static_cache_handler ||
          PagesCore::StaticCache::NullHandler.new
      end
    end
  end
end
