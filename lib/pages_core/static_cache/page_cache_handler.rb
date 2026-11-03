# frozen_string_literal: true

module PagesCore
  module StaticCache
    class PageCacheHandler
      def cache_page(controller, request, _response)
        return unless cacheable_query?(request)

        controller.class.page_cache_directory = page_cache_directory
        controller.cache_page
      end

      def cache_page_permanently(controller, request, _response)
        return unless cacheable_query?(request)

        controller.class.page_cache_directory = permanent_page_cache_directory
        controller.cache_page
      end

      def purge!
        return unless PagesCore::CacheSweeper.enabled

        clear_directory(page_cache_directory)
        clear_directory(permanent_page_cache_directory)
      end

      def sweep!
        return unless PagesCore::CacheSweeper.enabled

        PagesCore::SweepCacheJob.perform_later
      end

      def sweep_now!
        return unless PagesCore::CacheSweeper.enabled

        clear_directory(page_cache_directory)
      end

      private

      def cacheable_query?(request)
        request.query_parameters.keys.all? do |key|
          PagesCore::StaticCache.tracking_parameter?(key)
        end
      end

      def cache_root
        Rails.public_path
      end

      def clear_directory(path)
        return unless File.exist?(path)

        FileUtils.rm_rf(Dir.glob("#{path}/*"))
      end

      def page_cache_directory
        cache_root.join("static_cache")
      end

      def permanent_page_cache_directory
        cache_root.join("cache")
      end
    end
  end
end
