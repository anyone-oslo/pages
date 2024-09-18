# frozen_string_literal: true

module PagesCore
  module FrontendHelper
    include PagesCore::FeedTagsHelper
    include PagesCore::HeadTagsHelper

    def root_pages
      @root_pages ||= Page.roots.localized(content_locale).published
    end

    def root_page
      @root_page ||= root_pages.first
    end

    attr_reader :search_query
  end
end
