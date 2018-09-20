module Admin
  class ImageSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers
    include DynamicImage::Helper

    attributes :id, :filename, :content_type, :content_hash, :content_length,
               :colorspace, :real_width, :real_height, :crop_width,
               :crop_height, :crop_start_x, :crop_start_y, :crop_gravity_x,
               :crop_gravity_y, :alternative, :caption, :created_at, :updated_at
    attributes :cropped_url, :uncropped_url, :original_url

    def alternative
      localized_attribute(:alternative)
    end

    def caption
      localized_attribute(:caption)
    end

    def original_url
      original_dynamic_image_path(object)
    end

    def cropped_url
      dynamic_image_path(
        object,
        size: "1200x1200",
        crop: false,
        upscale: false
      )
    end

    def uncropped_url
      uncropped_dynamic_image_path(
        object,
        size: "2000x2000",
        upscale: false
      )
    end

    private

    def localized_attribute(attr)
      object.locales.each_with_object({}) do |locale, hash|
        hash[locale] = object.localize(locale).send(attr)
      end
    end
  end
end
