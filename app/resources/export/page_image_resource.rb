# frozen_string_literal: true

module Export
  class PageImageResource
    include Alba::Resource

    attributes :primary

    attribute :id do
      object.image.id
    end

    attribute :name do
      object.image.name
    end

    attribute :alternative do
      object.image.alternative
    end

    attribute :caption do
      object.image.caption
    end

    attribute :content_hash do
      object.image.content_hash
    end

    attribute :content_type do
      object.image.content_type
    end

    attribute :filename do
      object.image.filename
    end

    attribute :size do
      object.image.crop_size
    end

    attribute :created_at do
      object.image.created_at
    end
  end
end
