module Admin
  class PageFileSerializer < ActiveModel::Serializer
    attributes :id, :attachment_id, :image_id, :position
    has_one :attachment, serializer: Admin::AttachmentSerializer
  end
end
