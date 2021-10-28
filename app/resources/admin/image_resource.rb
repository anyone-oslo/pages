# frozen_string_literal: true

module Admin
  class ImageResource
    include Alba::Resource
    include Rails.application.routes.url_helpers
    include DynamicImage::Helper

    attributes :id, :filename, :content_type, :content_hash, :content_length,
               :colorspace, :real_width, :real_height, :crop_width,
               :crop_height, :crop_start_x, :crop_start_y, :crop_gravity_x,
               :crop_gravity_y, :created_at, :updated_at

    attribute :alternative do
      localized_attribute(:alternative)
    end

    attribute :caption do
      localized_attribute(:caption)
    end

    attribute :original_url do
      original_dynamic_image_path(object)
    end

    attribute :thumbnail_url do
      dynamic_image_path(
        object,
        size: "500x",
        upscale: false
      )
    end

    attribute :cropped_url do
      dynamic_image_path(
        object,
        size: "1200x1200",
        crop: false,
        upscale: false
      )
    end

    attribute :uncropped_url do
      uncropped_dynamic_image_path(
        object,
        size: "2000x2000",
        upscale: false
      )
    end

    private

    def localized_attribute(attr)
      object.locales.index_with do |locale|
        object.localize(locale).send(attr)
      end
    end
  end
end
