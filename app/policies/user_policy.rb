class UserPolicy < Policy
  def create?
    user.has_role?(:users)
  end

  alias_method :new?, :create?
  alias_method :destroy?, :create?

  def edit?
    user == record || user.has_role?(:users)
  end

  alias_method :delete_image?, :edit?
  alias_method :update?, :edit?
  alias_method :update_openid?, :edit?
end