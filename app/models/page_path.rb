# encoding: utf-8

class PagePath < ActiveRecord::Base
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
      existing = get(locale, path)

      return create(locale: locale, path: path, page: page) unless existing

      existing.update(page: page) unless existing.page_id == page.id
      existing
    end
  end
end
