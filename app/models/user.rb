# encoding: utf-8

class User < ActiveRecord::Base
  include PagesCore::HasRoles

  attr_accessor :password, :confirm_password

  belongs_to :creator, class_name: "User", foreign_key: 'created_by'
  has_many :created_users, class_name: "User", foreign_key: 'created_by'
  has_many :pages
  has_many :password_reset_tokens, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :invites, dependent: :destroy
  belongs_to_image :image, foreign_key: :image_id

  serialize :persistent_data

  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false }

  validates :name,
            presence: true

  validates :email,
            presence: true,
            format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i },
            uniqueness: { case_sensitive: false }

  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 8 }, allow_blank: true

  validate :confirm_password_must_match

  before_validation :ensure_username
  before_validation :hash_password
  before_create     :ensure_first_user_has_all_roles

  after_save ThinkingSphinx::RealTime.callback_for(:user)

  scope :by_name,     -> { order('name ASC') }
  scope :activated,   -> { by_name.includes(:roles).where(activated: true) }
  scope :deactivated, -> { by_name.includes(:roles).where(activated: false) }

  class << self
    def authenticate(email, password:)
      if user = User.find_by_username_or_email(email)
        if user.authenticate!(password)
          user
        end
      end
    end

    # Finds a user by either username or email address.
    def find_by_username_or_email(string)
      where(username: string.to_s).first ||
      where(email: string.to_s).first
    end
  end

  def authenticate!(password)
    if can_login? && valid_password?(password)
      rehash_password!(password) if password_needs_rehash?
      true
    else
      false
    end
  end

  def generate_new_password
    collection = "abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ123456789!#$%&/()=?+-_".chars
    pass = ""
    20.times{ pass << collection[rand(collection.size)] }
    self.confirm_password = self.password = pass
    pass
  end

  def can_login?
    self.activated?
  end

  def mark_active!
    if !self.last_login_at? || self.last_login_at < 10.minutes.ago
      self.update_columns(last_login_at: Time.now)
    end
  end

  def name_and_email
    "#{self.name} <#{self.email}>"
  end

  def online?
    (self.last_login_at && self.last_login_at > 15.minutes.ago) ? true : false
  end

  def purge_preferences!
    self.update(persistent_data: {})
  end

  def realname
    name
  end

  def to_xml(options={})
    options[:except]  ||= [:hashed_password, :persistent_params]
    options[:include] ||= [:image]
    super options
  end

  private

  def confirm_password_must_match
    if !password.blank? && password != confirm_password
      errors.add(:confirm_password, 'does not match')
    end
  end

  def encrypt_password(password)
    BCrypt::Password.create(password)
  end

  def ensure_username
    self.username ||= self.email
  end

  def ensure_first_user_has_all_roles
    unless User.any?
      self.activated = true
      Role.roles.each do |role|
        self.roles.new(name: role.name)
      end
    end
  end

  def hash_password
    unless password.blank?
      self.hashed_password = encrypt_password(password)
    end
  end

  def password_needs_rehash?
    self.hashed_password.length <= 40
  end

  def rehash_password!(password)
    self.update(hashed_password: encrypt_password(password))
  end

  def valid_password?(password)
    if self.hashed_password.length <= 40
      if self.hashed_password == Digest::SHA1.hexdigest(password)
        return true
      end
    else
      if BCrypt::Password.new(self.hashed_password) == password
        return true
      end
    end
    return false
  end
end
