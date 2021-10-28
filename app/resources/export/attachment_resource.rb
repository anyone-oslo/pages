# frozen_string_literal: true

module Export
  class AttachmentResource
    include Alba::Resource

    attributes :id, :filename, :content_type, :content_length, :content_hash,
               :created_at, :updated_at
  end
end
