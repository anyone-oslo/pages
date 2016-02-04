class PageTreeSerializer < ActiveModel::Serializer
  attributes :id, :param, :parent_page_id, :locale, :status, :news_page
  attributes :name
  attributes :published_at, :pinned

  has_many :children, serializer: PageTreeSerializer

  def children
    object.subpages.visible.in_locale(object.locale)
  end

  def param
    object.to_param
  end
end
