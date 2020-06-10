# frozen_string_literal: true

module PagesCore
  class ArchiveFinder
    def initialize(relation, options = {})
      @relation = relation
      @options = options
    end

    def by_year(year)
      filter_by_time(range_for_year(year))
    end

    def by_year_and_maybe_month(year, month = nil)
      return by_year(year) unless month

      by_year_and_month(year, month)
    end

    def by_year_and_month(year, month)
      filter_by_time(range_for_year_and_month(year, month))
    end

    def latest_year
      latest_year_and_month&.first
    end

    def latest_year_and_month
      ordered_relation.first.try do |record|
        [record[timestamp_attribute].year,
         record[timestamp_attribute].month]
      end
    end

    def months_in_year(year)
      select_months(by_year(year)).map(&:to_i).sort
    end

    def months_in_year_with_count(year)
      group_by_month(by_year(year))
        .count
        .to_a
        .sort_by(&:first)
    end

    def timestamp_attribute
      @options[:timestamp] || :created_at
    end

    def years
      select_years(@relation).map(&:to_i).sort
    end

    def years_with_count
      years.map { |year| [year, by_year(year).count] }
    end

    private

    def group_by_month(relation)
      relation.reorder("").group(Arel.sql(month_part))
    end

    def filter_by_time(range)
      @relation.where(
        "#{timestamp_attribute} >= ? AND #{timestamp_attribute} <= ?",
        range.first,
        range.last
      )
    end

    def month_part
      "date_part('month', #{timestamp_attribute})::integer"
    end

    def range_for_year(year)
      start_time = Time.new(year.to_i, 1, 1)
      end_time = start_time.end_of_year
      (start_time.in_time_zone)..(end_time.in_time_zone)
    end

    def range_for_year_and_month(year, month)
      start_time = Time.new(year.to_i, month, 1)
      end_time = start_time.end_of_month
      (start_time.in_time_zone)..(end_time.in_time_zone)
    end

    def select_months(relation)
      relation.reorder("").pluck(Arel.sql("DISTINCT #{month_part}"))
    end

    def select_years(relation)
      relation.reorder("").pluck(Arel.sql("DISTINCT #{year_part}"))
    end

    def ordered_relation
      @relation.reorder("#{timestamp_attribute} DESC")
    end

    def year_part
      "date_part('year', #{timestamp_attribute})"
    end
  end
end
