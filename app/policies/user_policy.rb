class UserPolicy < Policy
  module Collection
    def index?
      true
    end

    def deactivated?
      index?
    end

    def new?
      (!User.any?) || user.has_role?(:users)
    end

    def create?
      new?
    end

    def create_first?
      new?
    end

    def manage?
      new?
    end
  end

  module Member
    def edit?
      user == record || user.has_role?(:users)
    end

    def show?
      edit?
    end

    def delete_image?
      edit?
    end

    def policies?
      user.has_role?(:users)
    end

    def destroy?
      user.has_role?(:users)
    end
  end

  def change_password?
    user == record
  end
end