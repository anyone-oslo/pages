# frozen_string_literal: true

class PagePath < ApplicationRecord
  class PageNotSavedError < StandardError; end

  class NoPathError < StandardError; end

  class NoLocaleError < StandardError; end

  belongs_to :page
  validates :locale, presence: true
  validates :path, presence: true, uniqueness: { scope: :locale }

  class << self
    def build(page)
      page.locales.each do |locale|
        localized = page.localize(locale)
        localized.ensure_path_segment
        associate(localized) if !localized.deleted? && localized.full_path?
      end
      page.children.each { |p| build(p) }
    end

    def build_all
      Page.roots.each do |p|
        build(p)
      end
    end

    def get(locale, path)
      find_by(locale: locale, path: path)
    end

    def associate(page, locale: nil, path: nil)
      locale ||= page.locale
      path ||= page.full_path
      raise PageNotSavedError unless page.id?
      raise NoLocaleError unless locale
      raise NoPathError unless path

      page_path = get_or_create(locale, path, page)
      page_path.update(page: page) unless page_path.page_id == page.id
      page_path
    end

    private

    def get_or_create(locale, path, page)
      get(locale, path) || create(locale: locale, path: path, page: page)
    end
  end
end
