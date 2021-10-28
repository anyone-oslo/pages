# frozen_string_literal: true

module Admin
  class PageFileResource
    include Alba::Resource

    attributes :id, :page_id, :attachment_id, :position
    one :attachment, resource: Admin::AttachmentResource
  end
end
