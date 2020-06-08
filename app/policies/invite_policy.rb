# frozen_string_literal: true

class InvitePolicy < Policy
  def index?
    true
  end

  def reorder?
    user.role?(:users)
  end

  def new?
    user.role?(:users)
  end

  def show?
    true
  end

  def edit?
    user.role?(:users)
  end

  def accept?
    true
  end

  def policies?
    user.role?(:users)
  end
end
