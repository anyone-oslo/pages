# frozen_string_literal: true

class Invite < ApplicationRecord
  include PagesCore::HasRoles

  belongs_to :user
  has_many :roles, class_name: "InviteRole", dependent: :destroy

  before_validation :ensure_token

  validates :email,
            presence: true,
            format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i },
            uniqueness: { case_sensitive: false }

  validates :token, presence: true

  private

  def ensure_token
    self.token ||= SecureRandom.hex(32)
  end
end
