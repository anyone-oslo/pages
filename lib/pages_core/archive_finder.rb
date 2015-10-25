# encoding: utf-8

module PagesCore
  class ArchiveFinder
    def initialize(relation, options = {})
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
      select_months(by_year(year)).map(&:to_i).sort
    end

    def months_in_year_with_count(year)
      group_by_month(by_year(year))
        .count
        .to_a
        .sort { |a, b| a.first <=> b.first }
    end

    def timestamp_attribute
      @options[:timestamp] || :created_at
    end

    def years
      select_years(@relation).map(&:to_i).sort
    end

    private

    def group_by_month(relation)
      if mysql?
        relation.group("MONTH(#{timestamp_attribute})")
      else
        relation
          .reorder("")
          .group("date_part('month', #{timestamp_attribute})")
      end
    end

    def filter_by_time(range)
      @relation.where(
        "#{timestamp_attribute} >= ? AND #{timestamp_attribute} <= ?",
        range.first,
        range.last
      )
    end

    def mysql?
      ActiveRecord::Base.connection.adapter_name.downcase.starts_with?("mysql")
    end

    def range_for_year(year)
      date_time = DateTime.new(year.to_i, 1, 1)
      date_time..date_time.end_of_year
    end

    def range_for_year_and_month(year, month)
      date_time = DateTime.new(year.to_i, month.to_i, 1)
      date_time..date_time.end_of_month
    end

    def select_months(relation)
      if mysql?
        relation.pluck("DISTINCT MONTH(#{timestamp_attribute})")
      else
        relation
          .reorder("")
          .pluck("DISTINCT date_part('month', #{timestamp_attribute})")
      end
    end

    def select_years(relation)
      if mysql?
        relation.pluck("DISTINCT YEAR(#{timestamp_attribute})")
      else
        relation
          .reorder("")
          .pluck("DISTINCT date_part('year', #{timestamp_attribute})")
      end
    end

    def ordered_relation
      @relation.reorder("#{timestamp_attribute} DESC")
    end
  end
end
