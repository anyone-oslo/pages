# frozen_string_literal: true

module PagesCore
  module StaticCache
    class NullHandler
      def cache_page(_controller, _request, _response); end

      def cache_page_permanently(_controller, _request, _response); end

      def purge!; end

      def sweep!; end

      def sweep_now!; end
    end
  end
end
