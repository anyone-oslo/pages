# frozen_string_literal: true

module PagesCore
  module StaticCache
    class VarnishHandler
      def cache_page(controller, request, response)
        response.set_header("X-Static-Cache", "true")
        request.session_options[:skip] = true
        controller.expires_in 1.hour, public: true
      end

      def cache_page_permanently(controller, request, response)
        response.set_header("X-Permanent-Cache", "true")
        request.session_options[:skip] = true
        controller.expires_in 1.year, public: true
      end

      def purge!
        return unless PagesCore::CacheSweeper.enabled

      end

      def sweep!
        return unless PagesCore::CacheSweeper.enabled

        PagesCore::SweepCacheJob.perform_later
      end

      def sweep_now!
        return unless PagesCore::CacheSweeper.enabled

      end
    end
  end
end
