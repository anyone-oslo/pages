class UserCollectionPolicy < CollectionPolicy
  def index?
    true
  end

  alias_method :deactivated?, :index?

  def new?
    user.has_role?(:users) || !User.any?
  end

  alias_method :create?, :new?
  alias_method :create_first?, :new?

  def manage?
    user.has_role?(:users)
  end
end