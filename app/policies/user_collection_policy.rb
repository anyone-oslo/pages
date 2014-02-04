class UserCollectionPolicy < CollectionPolicy
  def index?
    true
  end

  def new?
    user.has_role?(:users)
  end

  def manage?
    user.has_role?(:users)
  end
end