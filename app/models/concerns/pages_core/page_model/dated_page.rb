# frozen_string_literal: true

module PagesCore
  module PageModel
    module DatedPage
      extend ActiveSupport::Concern

      included do
        before_validation :set_all_day_dates
        before_validation :ensure_ends_at

        scope :upcoming, -> { where("ends_at > ?", Time.zone.now) }
        scope :past, -> { where(ends_at: ..Time.zone.now) }
        scope :with_dates, -> { where.not(starts_at: nil) }
      end

      module ClassMethods
        def count_by_month
          connection.select_all(count_by_month_query).map(&:symbolize_keys)
        end

        def in_year(year)
          time = Date.new(year.to_i).to_time
          where("ends_at >= ? AND starts_at <= ?",
                time.beginning_of_year,
                time.end_of_year)
        end

        def in_year_and_month(year, month)
          time = Date.new(year.to_i, month.to_i).to_time
          where("ends_at >= ? AND starts_at <= ?",
                time.beginning_of_month,
                time.end_of_month)
        end

        private

        def count_by_month_query
          <<-SQL.squish
            SELECT extract('year' FROM s.d)::integer AS year,
                   extract('month' FROM s.d)::integer AS month,
                   count(p.id) AS count
            FROM (SELECT generate_series(
                    date_trunc('month', min(starts_at)::date),
                    max(ends_at)::date,
                    '1 month'::interval)::date AS d FROM pages) s
            RIGHT JOIN pages p
              ON p.ends_at::date >= s.d
              AND p.starts_at::date <= (s.d + interval '1 month - 1 day')::date
            WHERE p.starts_at IS NOT NULL
            GROUP BY s.d
            ORDER BY s.d DESC
          SQL
        end
      end

      # Finds the page's next sibling by date. Returns nil if there
      # isn't one.
      def next_sibling_by_date
        siblings_by_date.where(starts_at: starts_at..)&.first
      end

      # Finds the page's previous sibling by date. Returns nil if
      # there isn't one.
      def previous_sibling_by_date
        siblings_by_date.where(starts_at: ...starts_at)&.last
      end

      def upcoming?
        return false unless ends_at?

        ends_at > Time.zone.now
      end

      private

      def ensure_ends_at
        return unless starts_at?

        self.ends_at = starts_at if !ends_at? || ends_at < starts_at
      end

      def set_all_day_dates
        return unless all_day?

        self.starts_at = starts_at.beginning_of_day if starts_at?
        self.ends_at = ends_at.end_of_day if ends_at?
      end

      def siblings_by_date
        siblings.reorder("starts_at ASC, pages.id DESC")
                .where
                .not(id:)
      end
    end
  end
end
