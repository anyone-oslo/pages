# frozen_string_literal: true

module PagesCore
  module StaticCache
    class PageCacheHandler
      def cache_page(controller, _request, _response)
        controller.class.page_cache_directory = page_cache_directory
        controller.cache_page
      end

      def cache_page_permanently(controller, _request, _response)
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

      def cache_root
        Rails.root.join("public")
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
