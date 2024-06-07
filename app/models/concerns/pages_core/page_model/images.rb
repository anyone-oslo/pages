# frozen_string_literal: true

module PagesCore
  module PageModel
    module Images
      extend ActiveSupport::Concern

      included do
        belongs_to_image :image, optional: true
        belongs_to_image :meta_image, class_name: "Image", optional: true
        has_many :page_images, -> { order("position") },
                 inverse_of: :page,
                 dependent: :destroy
        has_many(
          :images,
          -> { where(page_images: { primary: false }).order("position") },
          through: :page_images
        )

        after_save :update_primary_image

        accepts_nested_attributes_for(
          :page_images,
          reject_if: proc { |a| a["image_id"].blank? },
          allow_destroy: true
        )
      end

      def image?
        image_id?
      end

      def image
        super.try { |i| i.localize(locale) }
      end

      def images
        super.in_locale(locale)
      end

      def page_images
        super.in_locale(locale)
      end

      def page_images_attributes=(attrs)
        ids = page_images.map(&:id)
        super(attrs.reject { |a| a["_destroy"] && ids.exclude?(a["id"]) })
      end

      private

      def update_primary_image
        new_id = page_images.find_by(primary: true)&.image_id
        update(image_id: new_id) if new_id != image_id
      end
    end
  end
end
