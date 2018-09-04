class UserPolicy < Policy
  def index?
    true
  end

  def deactivated?
    index?
  end

  def new?
    User.none? || user.role?(:users)
  end

  def create?
    new?
  end

  def login?
    true
  end

  def manage?
    new?
  end

  def edit?
    user == record || user.role?(:users)
  end

  def show?
    edit?
  end

  def delete_image?
    edit?
  end

  def policies?
    user.role?(:users)
  end

  def destroy?
    user.role?(:users)
  end

  def change_password?
    user == record
  end
end
