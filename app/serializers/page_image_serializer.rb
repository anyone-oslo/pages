class PageImageSerializer < ActiveModel::Serializer
  attributes :id, :image_id, :primary, :filename, :name, :byline, :created_at

  def name
    object.image.name
  end

  def byline
    object.image.byline
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