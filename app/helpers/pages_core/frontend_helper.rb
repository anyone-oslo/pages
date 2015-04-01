# encoding: utf-8

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

    def comment_honeypot_field
      text_field_tag "email", "", class: "comment_email"
    end
  end
end
