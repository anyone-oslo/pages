# encoding: utf-8

module PagesCore
  class ArchiveFinder
    def initialize(relation, options={})
      @relation, @options = relation, options
    end

    def by_year(year)
      filter_by_time(range_for_year(year))
    end

    def by_year_and_month(year, month)
      filter_by_time(range_for_year_and_month(year, month))
    end

    def latest_year_and_month
      ordered_relation.first.try do |record|
        [
          record[timestamp_attribute].year,
          record[timestamp_attribute].month
        ]
      end
    end

    def months_in_year(year)
      by_year(year)
        .reorder("#{timestamp_attribute} ASC")
        .group("MONTH(#{timestamp_attribute})")
        .map { |record| record[timestamp_attribute].month }
    end

    def months_in_year_with_count(year)
      by_year(year)
        .group("MONTH(#{timestamp_attribute})")
        .count
        .to_a
    end

    def timestamp_attribute
      @options[:timestamp] || :created_at
    end

    def years
      @relation
        .reorder("#{timestamp_attribute} ASC")
        .group("YEAR(#{timestamp_attribute})")
        .map { |record| record[timestamp_attribute].year }
    end

    private

    def filter_by_time(range)
      @relation.where("#{timestamp_attribute} >= ? AND #{timestamp_attribute} <= ?", range.first, range.last)
    end

    def range_for_year(year)
      date_time = DateTime.new(year.to_i, 1, 1)
      date_time..date_time.end_of_year
    end

    def range_for_year_and_month(year, month)
      date_time = DateTime.new(year.to_i, month.to_i, 1)
      date_time..date_time.end_of_month
    end

    def ordered_relation
      @relation.reorder("#{timestamp_attribute} DESC")
    end
  end
end