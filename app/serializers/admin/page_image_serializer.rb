class Admin::PageImageSerializer < ActiveModel::Serializer
  attributes :id, :page_id, :image_id, :position, :primary
  has_one :image
end
