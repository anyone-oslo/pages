# frozen_string_literal: true

module PagesCore
  module Admin
    module DeprecatedAdminHelper
      def page_description=(description)
        ActiveSupport::Deprecation.warn(content_helper_deprecation)
        content_for(:page_description, description.html_safe)
      end
      alias page_description page_description=

      def page_description_links=(links)
        ActiveSupport::Deprecation.warn(content_helper_deprecation)
        content_for(:page_description_links, links.html_safe)
      end
      alias page_description_links page_description_links=

      def page_title=(title)
        ActiveSupport::Deprecation.warn(content_helper_deprecation)
        content_for(:page_title, title)
      end
      alias page_title page_title=

      private

      def content_helper_deprecation
        name = caller_locations(1, 1)[0].label
        replacement = name.gsub(/=$/, "")

        "The #{name} helper is deprecated, use content_for(:#{replacement})"
      end
    end
  end
end
