# frozen_string_literal: true

class User < ApplicationRecord
  include PagesCore::HasOtp
  include PagesCore::HasRoles

  has_secure_password

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

  validates :password,
            length: {
              minimum: 8,
              maximum: ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED,
              allow_blank: true
            }

  before_save :update_session_token
  before_create :ensure_first_user_has_all_roles

  scope :by_name,     -> { order("name ASC") }
  scope :activated,   -> { by_name.includes(:roles).where(activated: true) }
  scope :deactivated, -> { by_name.includes(:roles).where(activated: false) }

  class << self
    def authenticate(email, password:)
      User.find_by_email(email).try(:authenticate, password)
    end

    def find_by_email(str)
      find_by("LOWER(email) = ?", str.to_s.downcase)
    end
  end

  def authenticate!(password)
    return false unless can_login? && valid_password?(password)

    rehash_password!(password) if password_needs_rehash?
    true
  end

  def can_login?
    activated?
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

  def update_session_token
    return unless !session_token? || password_digest_changed?

    self.session_token = SecureRandom.hex(32)
  end
end
