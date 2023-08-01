# frozen_string_literal: true

module PagesCore
  module FrontendHelper
    def root_pages
      @root_pages ||= Page.roots.localized(content_locale).published
    end

    def root_page
      @root_page ||= root_pages.first
    end

    attr_reader :search_query, :search_category_id
  end
end
