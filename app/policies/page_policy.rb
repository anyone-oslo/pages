class PagePolicy < Policy
  module Collection
    def index?
      true
    end

    def news?
      true
    end

    def deleted?
      index?
    end

    def new?
      user.role?(:pages)
    end

    def new_news?
      create?
    end
  end

  module Member
    def show?
      true
    end

    def edit?
      user.role?(:pages)
    end

    def move?
      edit?
    end

    def delete_meta_image?
      edit?
    end
  end
end
