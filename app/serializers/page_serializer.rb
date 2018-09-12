class PageSerializer < ActiveModel::Serializer
  attributes :id, :param, :parent_page_id, :locale
  attributes(*PagesCore::Template.block_ids)
  attributes :published_at, :pinned

  has_one :image
  has_many :images
  has_many :pages

  def param
    object.to_param
  end

  def image
    object.page_images.where(primary: true).try(:first)
  end

  def images
    object.page_images
  end
end
