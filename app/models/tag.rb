# encoding: utf-8

class Tag < ActiveRecord::Base
  has_many :taggings

  class << self
      def tags_and_suggestions_for(taggable, options={})
        options = {
          limit: 100
        }.merge(options)
        tags = taggable.tags
        if tags.count < options[:limit]
          suggestions = Tag.joins(:taggings)
                           .select("`tags`.*, COUNT(`tags`.id) AS counter")
                           .group("`tags`.id")
                           .order("counter DESC")
                           .limit(options[:limit])
          suggestions = suggestions.reject{|t| tags.include?(t)}
          if suggestions.any?
            tags = tags.to_a + suggestions[0...(options[:limit] - tags.length)]
          end
        end
        tags
      end

    def parse(*tags)
      Array(tags).flatten
        .map{ |tag| tag.kind_of?(Tag) ? tag.name : tag }
        .map{ |tag| tag.split(",") }
        .flatten
        .map{ |tag| tag.strip }
    end
  end

  def tagged
    @tagged ||= taggings.collect { |tagging| tagging.taggable }
  end

  def on(taggable)
    taggings.create(taggable: taggable)
  end

  def ==(comparison_object)
    super || name == comparison_object.to_s
  end

  def to_s
    name
  end
end
