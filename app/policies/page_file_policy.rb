class PageFilePolicy < Policy
  def show?
    true
  end

  def edit?
    user.has_role?(:pages)
  end
end