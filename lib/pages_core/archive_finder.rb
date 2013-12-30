# encoding: utf-8

module PagesCore
  class ArchiveFinder
    def initialize(relation, options={})
      @relation, @options = relation, options
    end

    def by_year_and_month(year, month)
      date_time = DateTime.new(year.to_i, month.to_i, 1)
      @relation.where("#{timestamp_attribute} >= ? AND #{timestamp_attribute} <= ?", date_time, date_time.end_of_month)
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
      range_for_year(year)
        .select("DISTINCT MONTH(#{timestamp_attribute}) AS month")
        .order("month ASC")
        .map(&:month)
    end

    def months_in_year_with_count(year)
      range_for_year(year)
        .select("MONTH(#{timestamp_attribute}) AS month, COUNT(id) AS count")
        .group("MONTH(#{timestamp_attribute})")
        .order("month ASC")
        .map { |r| [r.month, r.count] }
    end

    def timestamp_attribute
      @options[:timestamp] || :created_at
    end

    def years
      @relation.select("DISTINCT YEAR(#{timestamp_attribute}) AS year")
               .order("year ASC")
               .map(&:year)
    end

    private

    def range_for_year(year)
      date_time = DateTime.new(year.to_i, 1, 1)
      @relation.where("#{timestamp_attribute} >= ? AND #{timestamp_attribute} <= ?", date_time, date_time.end_of_year)
    end

    def ordered_relation
      @relation.reorder("#{timestamp_attribute} DESC")
    end
  end
end