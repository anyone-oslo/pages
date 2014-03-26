class PageSerializer < ActiveModel::Serializer
  attributes :id, :parent_page_id
  attributes *PagesCore::Templates::TemplateConfiguration.all_blocks
  attributes :published_at, :pinned

  has_one  :image
  has_many :images
  has_many :pages

  def image
    object.page_images.where(primary: true).try(:first)
  end

  def images
    object.page_images
  end
end