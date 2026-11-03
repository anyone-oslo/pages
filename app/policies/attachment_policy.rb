# frozen_string_literal: true

class AttachmentPolicy < Policy
  def create?
    user.roles.any?
  end

  def update?
    user.roles.any?
  end
end
