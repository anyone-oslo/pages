class InvitePolicy < Policy
  def index?
    true
  end

  def reorder?
    user.has_role?(:users)
  end

  def new?
    user.has_role?(:users)
  end

  def show?
    true
  end

  def edit?
    user.has_role?(:users)
  end

  def accept?
    true
  end

  def policies?
    user.has_role?(:users)
  end
end