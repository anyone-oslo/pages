# frozen_string_literal: true

class PagePolicy < Policy
  def index?
    true
  end

  def calendar?
    index?
  end

  def deleted?
    index?
  end

  def search?
    index?
  end

  def new?
    user&.role?(:pages)
  end

  def show?
    true
  end

  def edit?
    user&.role?(:pages)
  end

  def edit2?
    edit?
  end

  def move?
    edit?
  end

  def delete_meta_image?
    edit?
  end
end
