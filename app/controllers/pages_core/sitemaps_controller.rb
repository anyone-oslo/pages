# encoding: utf-8

module PagesCore
  class SitemapsController < ApplicationController
    include PagesCore::PagePathHelper
    caches_page :show

    def show
      @entries = formatted_entries
    end

    private

    def format_time(timestamp)
      if timestamp.is_a?(Date)
        timestamp.strftime("%Y-%m-%d")
      else
        timestamp.strftime("%Y-%m-%dT%H:%M:%S#{timestamp.formatted_offset}")
      end
    end

    def format_record(record)
      {
        loc: record_url(record),
        lastmod: format_time(record.updated_at)
      }
    end

    def formatted_entries
      records.map { |r| format_record(r) }
    end

    def locales
      if PagesCore.config.locales
        PagesCore.config.locales.keys
      else
        [I18n.default_locale]
      end
    end

    def localized?(record)
      record.is_a?(PagesCore::Localizable::InstanceMethods)
    end

    def pages
      ([Page.root.localize(I18n.default_locale)] +
        locales.flat_map do |locale|
          Page.published.localized(locale)
        end).uniq
    end

    def page_record_url(record)
      if record == Page.root && record.locale == I18n.default_locale
        root_url
      else
        page_url(record.locale, record)
      end
    end

    def record_url(record)
      if record.is_a?(Page)
        page_record_url(record)
      elsif localized?(record)
        polymorphic_url(record, locale: record.locale)
      else
        polymorphic_url(record)
      end
    end

    def records
      pages
    end
  end
end
