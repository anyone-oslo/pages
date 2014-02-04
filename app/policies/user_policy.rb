class UserPolicy < Policy
  def edit?
    user == record || user.has_role?(:users)
  end

  alias_method :delete_image?, :edit?
  alias_method :update_openid?, :edit?

  def policies?
    user.has_role?(:users)
  end

  def destroy?
    user.has_role?(:users)
  end
end