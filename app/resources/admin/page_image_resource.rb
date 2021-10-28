# frozen_string_literal: true

module Admin
  class PageImageResource
    include Alba::Resource

    attributes :id, :page_id, :image_id, :position, :primary
    one :image, resource: Admin::ImageResource
  end
end
