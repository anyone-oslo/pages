class PageSerializer < ActiveModel::Serializer
  attributes :id, :parent_page_id
  attributes *PagesCore::Templates::TemplateConfiguration.all_blocks
  attributes :published_at, :pinned

  has_many :pages
end