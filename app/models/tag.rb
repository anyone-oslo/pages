# encoding: utf-8

class Tag < ActiveRecord::Base
  has_many :taggings

  class << self
    def tags_and_suggestions_for(taggable, options = {})
      options = default_options.merge(options)
      tags = taggable.tags
      if tags.count < options[:limit]
        suggested = suggestions(tags, options)
        tags = tags.to_a + suggested[0...(options[:limit] - tags.length)]
      end
      tags
    end

    def parse(*tags)
      Array(tags).flatten
        .map { |tag| tag.is_a?(Tag) ? tag.name : tag }
        .map { |tag| tag.split(",") }
        .flatten
        .map(&:strip)
    end

    private

    def suggestions(tags, options = {})
      Tag.joins(:taggings)
        .select("`tags`.*, COUNT(`tags`.id) AS counter")
        .group("`tags`.id")
        .order("counter DESC")
        .limit(options[:limit])
        .reject { |t| tags.include?(t) }
    end

    def default_options
      { limit: 100 }
    end
  end

  def tagged
    @tagged ||= taggings.collect(&:taggable)
  end

  def on(taggable)
    taggings.create(taggable: taggable)
  end

  def ==(other)
    super || name == other.to_s
  end

  def to_s
    name
  end
end
