# encoding: utf-8

module PagesCore::FrontendHelper
  include PagesCore::Deprecations::DeprecatedFrontendHelpers

  def root_pages
    @root_pages ||= Page.roots.localized(@locale).published
  end

  def root_page
    @root_page ||= root_pages.first
  end

  def search_query
    @search_query
  end

  def search_category_id
    @search_category_id
  end

  def comment_honeypot_field
    text_field_tag 'email', '', :class => 'comment_email'
  end
end
