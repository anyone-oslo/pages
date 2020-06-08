# frozen_string_literal: true

module PagesCore
  module Admin
    module PageJsonHelper
      def page_json(page)
        { id: page.id, param: page.to_param,
          name: page.name,
          parent_page_id: page.parent_page_id,
          locale: page.locale, status: page.status,
          news_page: page.news_page,
          published_at: page.published_at,
          pinned: page.pinned?, starts_at: page.starts_at,
          permissions: page_permissions(page) }
      end

      def page_permissions(page)
        [(:edit if policy(page).edit?),
         (:create if policy(page).edit?)].compact
      end
    end
  end
end
