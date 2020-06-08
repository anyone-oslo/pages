# frozen_string_literal: true

class PageImageExportSerializer < ActiveModel::Serializer
  attributes :id, :primary, :content_hash, :content_type, :filename,
             :alternative, :caption, :created_at

  def id
    object.image.id
  end

  def name
    object.image.name
  end

  def alternative
    object.image.alternative
  end

  def caption
    object.image.caption
  end

  def content_hash
    object.image.content_hash
  end

  def content_type
    object.image.content_type
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
