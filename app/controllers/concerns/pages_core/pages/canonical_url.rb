# frozen_string_literal: true

module PagesCore
  module Pages
    module CanonicalUrl
      extend ActiveSupport::Concern

      private

      def canonical_path(page)
        if page.redirects?
          page.redirect_path(locale: page.locale)
        else
          page_path(page.locale, page,
                    { format: canonical_format, page: canonical_page }.compact)
        end
      end

      def canonicalize_url
        return if @page.redirects?
        return if request.path == canonical_path(@page)

        disable_static_cache!
        return if untracked_query_parameters.any?

        redirect_to(canonical_path_with_tracking_parameters(@page),
                    status: :moved_permanently)
      end

      def canonical_format
        params[:format] unless params[:format] == "html"
      end

      def canonical_page
        page_param if request.path_parameters[:page]
      end

      def canonical_path_with_tracking_parameters(page)
        query = request.query_parameters.except(*untracked_query_parameters)
        [canonical_path(page), query.to_query.presence].compact.join("?")
      end

      def untracked_query_parameters
        request.query_parameters.keys.reject do |key|
          PagesCore::StaticCache.tracking_parameter?(key)
        end
      end
    end
  end
end
