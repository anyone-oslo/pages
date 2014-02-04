class PagePolicy < Policy
  def edit?
    user.has_role?(:pages)
  end
end