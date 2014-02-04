class PagePolicy < Policy
  def edit?
    user == record.author || user.has_role?(:pages)
  end

  alias_method :update?, :edit?
  alias_method :destroy?, :edit?
end