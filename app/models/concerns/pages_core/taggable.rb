# frozen_string_literal: true

module PagesCore
  module Taggable
    extend ActiveSupport::Concern

    attr_accessor :new_tags

    included do
      has_many :taggings,
               as: :taggable,
               dependent: :destroy,
               inverse_of: :taggable
      has_many :tags, through: :taggings
      after_save :update_taggings
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
      @new_tags = Tag.parse(list)
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
      @new_tags || tags.by_name.map(&:name)
    end

    private

    def update_taggings
      return unless new_tags

      Tag.transaction do
        taggings.includes(:tag).where.not(tag: { name: new_tags }).destroy_all
        new_tags.map { |n| Tag.find_or_create_by(name: n) }
                .each { |t| taggings.create(tag: t) }
      end

      @new_tags = nil
    end
  end
end
