# frozen_string_literal: true

module Admin
  module CalendarsHelper
    def calendar_pages(locale)
      Page.where(
        id: Page.with_dates.visible.pluck(:parent_page_id).uniq.compact
      ).in_locale(locale)
    end

    def calendar_page_options(locale)
      options_for_select(
        calendar_pages(locale).map do |p|
          [page_name(p, include_parents: true).gsub("&raquo;", "»"), p.id]
        end
      )
    end

    def calendar_years_with_count
      calendar_counts.each_with_object({}) do |entry, obj|
        obj[entry[:year]] ||= 0
        obj[entry[:year]] += entry[:count]
      end
    end

    def calendar_months_count(year)
      calendar_counts.filter { |e| e[:year] == year }
                     .map { |e| [e[:month], e[:count]] }
    end

    private

    def calendar_counts
      @calendar_counts ||= Page.count_by_month
    end
  end
end
