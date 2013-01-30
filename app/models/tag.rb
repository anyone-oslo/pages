# encoding: utf-8

class Tag < ActiveRecord::Base
  has_many :taggings

  class << self
      def tags_and_suggestions_for(taggable, options={})
        options = {
          :limit => 100
        }.merge(options)
        tags = taggable.tags
        if taggable.tags.length < options[:limit]
          suggestions = Tag.all(
            :select => 'tags.*, count(tags.id) as counter',
            :joins => :taggings,
            :group => 'tags.id',
            :order => 'counter DESC',
            :limit => options[:limit]
          ).reject{|s| tags.include?(s)}
          if suggestions.length > 0
            tags += suggestions[0...(options[:limit] - tags.length)]
          end
        end
        tags
      end
  end

  def self.parse(list)

    # Parse comma separated tags
    tag_names = list.strip.split(/[\s]*,[\s]*/).delete_if{|t| t.empty?}

    # # Old style parsing:
    #
    # tag_names = []
    #
    # # first, pull out the quoted tags
    # list.gsub!(/\"(.*?)\"\s*/ ) { tag_names << $1; "" }
    #
    # # then, replace all commas with a space
    # list.gsub!(/,/, " ")
    #
    # # then, get whatever's left
    # tag_names.concat list.split(/\s/)
    #
    # # strip whitespace from the names
    # tag_names = tag_names.map { |t| t.strip }
    #
    # # delete any blank tag names
    # tag_names = tag_names.delete_if { |t| t.empty? }

    return tag_names
  end

  def tagged
    @tagged ||= taggings.collect { |tagging| tagging.taggable }
  end

  def on(taggable)
    taggings.create :taggable => taggable
  end

  def ==(comparison_object)
    super || name == comparison_object.to_s
  end

  def to_s
    name
  end
end
