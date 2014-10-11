class PagePolicy < Policy
  module Collection
    def index?
      true
    end

    def news?
      true
    end

    def new?
      user.has_role?(:pages)
    end

    def new_news?
      create?
    end

    def reorder_pages?
      create?
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