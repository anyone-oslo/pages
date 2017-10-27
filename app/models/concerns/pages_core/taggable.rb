module PagesCore
  module Taggable
    extend ActiveSupport::Concern

    included do
      has_many :taggings, as: :taggable, dependent: :destroy
      has_many :tags, through: :taggings
    end

    module ClassMethods
      def tagged_with(*tags)
        all
          .includes(:tags)
          .where("tags.name IN (?)", Tag.parse(tags))
          .references(:tags)
      end
    end

    def serialized_tags
      tags.order("name ASC").map(&:name).to_json
    end

    def serialized_tags=(json)
      tag_with(ActiveSupport::JSON.decode(json))
    end

    def tag_with(*list)
      Tag.transaction do
        taggings.destroy_all
        Tag.parse(list).each do |name|
          Tag.find_or_create_by(name: name).on(self)
        end
      end
    end

    def tag_list=(tag_list)
      tag_with(tag_list)
    end

    def tag_list
      tags.order("name ASC").map(&:name).join(", ")
    end
  end
end
