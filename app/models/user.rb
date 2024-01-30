# frozen_string_literal: true

class User < ApplicationRecord
  include PagesCore::AuthenticableUser
  include PagesCore::HasRoles

  belongs_to(:creator,
             class_name: "User",
             foreign_key: "created_by",
             optional: true,
             inverse_of: :created_users)
  has_many(:created_users,
           class_name: "User",
           foreign_key: "created_by",
           dependent: :nullify,
           inverse_of: :creator)
  has_many :pages, dependent: :nullify
  has_many :roles, dependent: :destroy
  has_many :invites, dependent: :destroy
  belongs_to_image :image, foreign_key: :image_id, optional: true

  serialize :persistent_data

  validates :name, presence: true

  validates :email,
            presence: true,
            format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i },
            uniqueness: { case_sensitive: false }

  before_create :ensure_first_user_has_all_roles

  scope :by_name,     -> { order("name ASC") }
  scope :activated,   -> { by_name.includes(:roles).where(activated: true) }
  scope :deactivated, -> { by_name.includes(:roles).where(activated: false) }

  class << self
    def find_by_email(str)
      find_by("LOWER(email) = ?", str.to_s.downcase.strip)
    end
  end

  def mark_active!
    return if last_login_at && last_login_at > 10.minutes.ago

    update(last_login_at: Time.now.utc)
  end

  def name_and_email
    "#{name} <#{email}>"
  end

  def online?
    last_login_at && last_login_at > 15.minutes.ago
  end

  def realname
    name
  end

  private

  def ensure_first_user_has_all_roles
    return if User.any?

    self.activated = true
    Role.roles.each do |r|
      roles.new(name: r.name) unless role?(r.name)
    end
  end
end
