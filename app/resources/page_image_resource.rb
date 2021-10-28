# frozen_string_literal: true

class PageImageResource
  include Alba::Resource
  include Rails.application.routes.url_helpers
  include DynamicImage::Helper

  attributes :id, :image_id, :primary

  attribute :alternative do
    object.image.alternative
  end

  attribute :caption do
    object.image.caption
  end

  attribute :filename do
    object.image.filename
  end

  attribute :created_at do
    object.image.created_at
  end

  attribute :url do
    dynamic_image_path(
      object.image,
      size: "2000x2000",
      crop: false,
      upscale: false
    )
  end
end
