class PageImageCollectionPolicy < CollectionPolicy
  def index?
    true
  end

  def reorder?
    user.has_role?(:pages)
  end

  def new?
    user.has_role?(:pages)
  end
end