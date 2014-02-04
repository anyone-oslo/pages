class PageCollectionPolicy < CollectionPolicy
  def index?
    true
  end

  def news?
    true
  end

  def new?
    user.has_role?(:pages)
  end

  alias_method :new_news?, :create?
  alias_method :reorder?, :create?
  alias_method :import_xml?, :create?
end