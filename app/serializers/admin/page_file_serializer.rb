module Admin
  class PageFileSerializer < ActiveModel::Serializer
    attributes :id, :page_id, :attachment_id, :position
    has_one :attachment, serializer: Admin::AttachmentSerializer
  end
end
