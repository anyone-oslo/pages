# frozen_string_literal: true

module PagesCore
  module StaticCacheController
    extend ActiveSupport::Concern

    included do
      helper_method :static_cached?
    end

    module ClassMethods
      def static_cache(*actions, permanent: false)
        before_action :prepare_static_cache
        if permanent
          after_action :cache_static_page_permanently, only: actions
        else
          after_action :cache_static_page, only: actions
        end
      end

      alias caches_page static_cache
    end

    def disable_static_cache!
      @static_cache_disabled = true
    end

    def static_cached?
      @static_cached ? true : false
    end

    private

    def cache_static_page
      return unless static_cache_allowed?

      PagesCore::StaticCache.handler.cache_page(
        self, request, response
      )
    end

    def cache_static_page_permanently
      return unless static_cache_allowed?

      PagesCore::StaticCache.handler.cache_page_permanently(
        self, request, response
      )
    end

    def prepare_static_cache
      @static_cached = true
    end

    def static_cache_allowed?
      (request.get? || request.head?) && response.status == 200 &&
        perform_caching && !@static_cache_disabled
    end
  end
end
