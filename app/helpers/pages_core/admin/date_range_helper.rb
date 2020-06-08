# frozen_string_literal: true

module PagesCore
  module Admin
    module DateRangeHelper
      def page_date_range(page)
        if page.all_day?
          date_range(page.starts_at.to_date, page.ends_at.to_date)
        else
          date_range(page.starts_at, page.ends_at)
        end
      end

      def date_range(starts_at, ends_at)
        dates = different_year_date_range(starts_at, ends_at) ||
                different_month_date_range(starts_at, ends_at) ||
                different_day_date_range(starts_at, ends_at) ||
                same_day_date_range(starts_at, ends_at)
        safe_join(dates.map(&:strip), "&ndash;".html_safe)
      end

      private

      def different_year_date_range(starts_at, ends_at)
        return if starts_at.year == ends_at.year

        [l(starts_at, format: :pages_full), l(ends_at, format: :pages_full)]
      end

      def different_month_date_range(starts_at, ends_at)
        return if starts_at.month == ends_at.month

        [l(starts_at, format: :pages_date), l(ends_at, format: :pages_full)]
      end

      def different_day_date_range(starts_at, ends_at)
        return if starts_at.day == ends_at.day

        if starts_at.is_a?(Date) && ends_at.is_a?(Date)
          [l(starts_at, format: :pages_day), l(ends_at, format: :pages_full)]
        else
          [l(starts_at, format: :pages_date), l(ends_at, format: :pages_full)]
        end
      end

      def same_day_date_range(starts_at, ends_at)
        if starts_at.is_a?(Date) && ends_at.is_a?(Date)
          [l(starts_at, format: :pages_full)]
        else
          [l(starts_at, format: :pages_full), l(ends_at, format: :pages_time)]
        end
      end
    end
  end
end
