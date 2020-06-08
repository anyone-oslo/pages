# frozen_string_literal: true

class InviteRole < ActiveRecord::Base
  belongs_to :invite
  validates :name,
            presence: true,
            uniqueness: { scope: :invite_id },
            inclusion: { in: proc { Role.roles.map(&:name) } }

  def to_s
    name.humanize
  end
end
