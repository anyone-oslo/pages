# frozen_string_literal: true

module PagesCore
  module Taggable
    extend ActiveSupport::Concern

    included do
      has_many :taggings,
               as: :taggable,
               dependent: :destroy,
               inverse_of: :taggable
      has_many :tags, through: :taggings
    end

    module ClassMethods
      def tagged_with(*tags)
        all.includes(:tags)
           .where(tags: { name: Tag.parse(tags) })
           .references(:tags)
      end
    end

    def serialized_tags
      tag_names.to_json
    end

    def serialized_tags=(json)
      tag_with(ActiveSupport::JSON.decode(json))
    end

    def tag_with(*list)
      self.tags = Tag.parse(list).map { |n| Tag.find_or_initialize_by(name: n) }
    end

    def tag_with!(*list)
      update(tag_list: list)
    end

    def tag_list=(tag_list)
      tag_with(tag_list)
    end

    def tag_list
      tag_names.join(", ")
    end

    def tag_names
      tags.by_name.map(&:name)
    end
  end
end
