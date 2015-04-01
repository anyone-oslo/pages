class PasswordResetToken < ActiveRecord::Base
  belongs_to :user
  before_create :ensure_token
  before_create :ensure_expiration

  validates :user_id, presence: true

  scope :active,  -> { where("expires_at >= ?", Time.now) }
  scope :expired, -> { where("expires_at < ?", Time.now) }

  class << self
    def default_expiration
      24.hours
    end

    def expire!
      expired.delete_all
    end

    def find_by_token(token)
      active.where(token: token).first
    end
  end

  def expired?
    expires_at < Time.now
  end

  private

  def ensure_expiration
    self.expires_at ||= Time.now + self.class.default_expiration
  end

  def ensure_token
    self.token ||= SecureRandom.hex(32)
  end
end
