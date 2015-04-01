class PageImageSerializer < ActiveModel::Serializer
  attributes :id, :image_id, :primary, :filename, :caption, :created_at

  def name
    object.image.name
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
end
