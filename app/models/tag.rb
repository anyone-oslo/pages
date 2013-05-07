# encoding: utf-8

class Tag < ActiveRecord::Base
  has_many :taggings

  class << self
      def tags_and_suggestions_for(taggable, options={})
        options = {
          limit: 100
        }.merge(options)
        tags = taggable.tags
        if taggable.tags.length < options[:limit]
          suggestions = Tag.all(
            select: 'tags.*, count(tags.id) as counter',
            joins: :taggings,
            group: 'tags.id',
            order: 'counter DESC',
            limit: options[:limit]
          ).reject{|s| tags.include?(s)}
          if suggestions.length > 0
            tags += suggestions[0...(options[:limit] - tags.length)]
          end
        end
        tags
      end

    def parse(tag_list)
      tag_list.strip.split(/[\s]*,[\s]*/).delete_if{|t| t.empty?}
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
