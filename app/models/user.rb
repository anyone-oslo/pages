# frozen_string_literal: true

class User < ActiveRecord::Base
  include PagesCore::HasRoles

  attr_accessor :password, :confirm_password

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
  has_many :password_reset_tokens, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :invites, dependent: :destroy
  belongs_to_image :image, foreign_key: :image_id, optional: true

  serialize :persistent_data

  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false }

  validates :name, presence: true

  validates :email,
            presence: true,
            format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i },
            uniqueness: { case_sensitive: false }

  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 8 }, allow_blank: true

  validate :confirm_password_must_match

  before_validation :ensure_username
  before_validation :hash_password
  before_create :ensure_first_user_has_all_roles

  scope :by_name,     -> { order("name ASC") }
  scope :activated,   -> { by_name.includes(:roles).where(activated: true) }
  scope :deactivated, -> { by_name.includes(:roles).where(activated: false) }

  class << self
    def authenticate(email, password:)
      user = User.login_name(email)
      user if user.try { |u| u.authenticate!(password) }
    end

    def find_by_email(str)
      find_by("LOWER(email) = ?", str.to_s.downcase)
    end

    # Finds a user by either username or email address.
    def login_name(string)
      find_by(username: string.to_s) || find_by_email(string)
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
    last_login_at && last_login_at > 15.minutes.ago ? true : false
  end

  def realname
    name
  end

  private

  def confirm_password_must_match
    return if password.blank? || password == confirm_password

    errors.add(:confirm_password, "does not match")
  end

  def encrypt_password(password)
    BCrypt::Password.create(password)
  end

  def ensure_username
    self.username ||= email
  end

  def ensure_first_user_has_all_roles
    return if User.any?

    self.activated = true
    Role.roles.each do |r|
      roles.new(name: r.name) unless role?(r.name)
    end
  end

  def hash_password
    self.hashed_password = encrypt_password(password) if password.present?
  end

  def password_needs_rehash?
    hashed_password.length <= 40
  end

  def rehash_password!(password)
    update(hashed_password: encrypt_password(password))
  end

  def valid_password?(password)
    if hashed_password.length <= 40
      hashed_password == Digest::SHA1.hexdigest(password)
    else
      BCrypt::Password.new(hashed_password) == password
    end
  end
end
