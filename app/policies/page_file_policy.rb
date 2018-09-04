class PageFilePolicy < Policy
  def index?
    true
  end

  def reorder?
    user.role?(:pages)
  end

  def new?
    user.role?(:pages)
  end

  def show?
    true
  end

  def edit?
    user.role?(:pages)
  end
end
