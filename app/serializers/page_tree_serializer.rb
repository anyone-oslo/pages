class PageTreeSerializer < ActiveModel::Serializer
  attributes :id, :param, :parent_page_id, :locale, :status
  attributes :name
  attributes :published_at, :pinned

  has_many :pages, serializer: PageTreeSerializer

  def param
    object.to_param
  end
end
