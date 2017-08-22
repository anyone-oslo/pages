# encoding: utf-8

module PagesCore
  module PageModel
    module Images
      extend ActiveSupport::Concern

      included do
        belongs_to_image :image, optional: true
        belongs_to_image :meta_image, class_name: "Image", optional: true
        has_many :page_images, -> { order("position") }
        has_many(
          :images,
          -> { where(page_images: { primary: false }).order("position") },
          through: :page_images
        )

        after_save :ensure_page_images_contains_primary_image
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

      private

      def ensure_page_images_contains_primary_image
        return unless image_id?
        page_image = page_images.find_by(image_id: image_id)
        if page_image
          page_image.update(primary: true) unless page_image.primary?
        else
          page_images.create(image_id: image_id, primary: true)
        end
      end
    end
  end
end
