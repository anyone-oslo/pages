class PageTreeSerializer < ActiveModel::Serializer
  attributes :id, :param, :parent_page_id, :locale, :status, :news_page
  attributes :name
  attributes :published_at, :pinned
  attributes :starts_at

  has_many :children, serializer: PageTreeSerializer

  def starts_at
    return nil unless object.starts_at?
    if object.all_day?
      I18n.l(object.starts_at.to_date, format: :long)
    else
      I18n.l(object.starts_at, format: :long)
    end
  end

  def children
    object.subpages.visible.in_locale(object.locale)
  end

  def param
    object.to_param
  end
end
