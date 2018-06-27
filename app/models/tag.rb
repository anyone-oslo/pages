class Tag < ActiveRecord::Base
  include PagesCore::HumanizableParam
  has_many :taggings, dependent: :destroy

  scope :pinned, -> { where(pinned: true) }
  scope :sorted, -> { order("pinned DESC, name ASC") }

  class << self
    def tags_and_suggestions_for(taggable, options = {})
      limit = options[:limit] || 100
      tags = (taggable.tags.sorted + pinned.sorted).uniq

      return tags unless tags.count < limit
      tags + suggestions(taggable, tags, limit)[0...(limit - tags.length)]
    end

    def parse(*tags)
      Array(tags).flatten
                 .map { |tag| tag.is_a?(Tag) ? tag.name : tag }
                 .map { |tag| tag.split(",") }
                 .flatten
                 .map(&:strip)
    end

    private

    def suggestions(taggable, tags, limit)
      suggestions = taggable_suggestions(taggable, limit).to_a
      if suggestions.length < limit
        suggestions += all_suggestions(limit)
      end
      suggestions.reject { |t| tags.include?(t) }.uniq[0...(limit)]
    end

    def taggable_suggestions(taggable, limit)
      all_suggestions(limit).where("taggings.taggable_type = ?", taggable.class)
    end

    def all_suggestions(limit)
      Tag.joins(:taggings)
         .select("tags.*, COUNT(tags.id) AS counter")
         .group("tags.id")
         .order("counter DESC")
         .limit(limit)
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

  def to_param
    humanized_param(name)
  end

  def to_s
    name
  end
end
