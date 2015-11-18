class PageTreeSerializer < ActiveModel::Serializer
  attributes :id, :param, :parent_page_id, :locale, :status
  attributes :name
  attributes :published_at, :pinned
  attributes :collapsed

  has_many :children, serializer: PageTreeSerializer

  def collapsed
    object.news_page?
  end

  def children
    object.pages
  end

  def param
    object.to_param
  end
end
