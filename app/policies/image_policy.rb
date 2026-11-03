# frozen_string_literal: true

class ImagePolicy < Policy
  def show?
    user.roles.any?
  end

  def create?
    user.roles.any?
  end

  def update?
    user.roles.any?
  end
end
