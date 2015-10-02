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
        if !localized.deleted? && localized.full_path?
          associate(localized)
        end
      end
      page.children.each { |p| build(p) }
    end

    def build_all
      Page.roots.each do |p|
        build(p)
      end
    end

    def get(locale, path)
      where(locale: locale, path: path).first
    end

    def associate(page, locale: nil, path: nil)
      locale ||= page.locale
      path ||= page.full_path
      fail PageNotSavedError unless page.id?
      fail NoLocaleError unless locale
      fail NoPathError unless path
      existing = get(locale, path)
      if existing
        existing.update(page: page) unless existing.page_id == page.id
        existing
      else
        create(locale: locale, path: path, page: page)
      end
    end
  end
end
