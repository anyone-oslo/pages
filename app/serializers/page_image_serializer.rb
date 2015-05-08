class PageImageSerializer < ActiveModel::Serializer
  include DynamicImage::Helper
  attributes :id, :image_id, :primary, :filename
  attributes :alternative, :caption, :created_at, :url

  def name
    object.image.name
  end

  def alternative
    object.image.alternative
  end

  def caption
    object.image.caption
  end

  def filename
    object.image.filename
  end

  def size
    object.image.crop_size
  end

  def created_at
    object.image.created_at
  end

  def url
    dynamic_image_path(
      object.image,
      size: "2000x2000",
      crop: false,
      upscale: false
    )
  end
end
