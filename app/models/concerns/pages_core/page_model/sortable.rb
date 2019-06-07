module PagesCore
  module PageModel
    module Sortable
      extend ActiveSupport::Concern

      included do
        acts_as_list scope: :parent_page
        after_save :check_list_position
      end

      module ClassMethods
        def order_by_tags(tags)
          joins(
            "LEFT JOIN taggings ON taggings.taggable_id = pages.id AND " \
            "taggings.tag_id IN (" + tags.map(&:id).join(",") + ") AND " \
            "taggings.taggable_type = #{ActiveRecord::Base.connection.quote('Page')}"
          )
            .group("pages.id, localizations.id")
            .reorder(Arel.sql("COUNT(taggings.id) DESC"))
        end
      end

      def reorderable_children?
        !news_page?
      end

      def reorderable?
        !parent || !parent.news_page?
      end

      def content_order
        if news_page?
          "pages.pinned DESC, published_at DESC"
        else
          "position ASC"
        end
      end

      private

      def check_list_position
        if deleted?
          remove_from_list
        elsif !position?
          assume_bottom_position
        end
      end
    end
  end
end
