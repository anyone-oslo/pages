module PagesCore
  module FrontendHelper
    def root_pages
      @root_pages ||= Page.roots.localized(@locale).published
    end

    def root_page
      @root_page ||= root_pages.first
    end

    attr_reader :search_query

    attr_reader :search_category_id
  end
end
