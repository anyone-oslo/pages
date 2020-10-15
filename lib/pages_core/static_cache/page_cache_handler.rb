# frozen_string_literal: true

module PagesCore
  module StaticCache
    class PageCacheHandler
      def cache_page(controller, _request, _response)
        controller.cache_page
      end

      def cache_page_permanently(controller, _request, _response)
        controller.cache_page
      end
    end
  end
end
