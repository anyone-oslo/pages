class PagePolicy < Policy
  def edit?
    user == record.author || user.has_role?(:pages)
  end
end