class PageFilePolicy < Policy
  module Collection
    def index?
      true
    end

    def reorder?
      user.has_role?(:pages)
    end

    def new?
      user.has_role?(:pages)
    end
  end

  module Member
    def show?
      true
    end

    def edit?
      user.has_role?(:pages)
    end
  end
end