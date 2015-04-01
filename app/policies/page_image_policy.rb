class PageImagePolicy < Policy
  module Collection
    def index?
      true
    end

    def reorder?
      user.role?(:pages)
    end

    def new?
      user.role?(:pages)
    end
  end

  module Member
    def show?
      true
    end

    def edit?
      user.role?(:pages)
    end
  end
end
