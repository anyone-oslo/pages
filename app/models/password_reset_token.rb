class PasswordResetToken < ActiveRecord::Base
  belongs_to :user
  before_create :ensure_token
  before_create :ensure_expiration

  validates :user_id, presence: true

  scope :active,  -> { where("expires_at >= ?", Time.now.utc) }
  scope :expired, -> { where("expires_at < ?", Time.now.utc) }

  class << self
    def default_expiration
      24.hours
    end

    def expire!
      expired.delete_all
    end
  end

  def expired?
    expires_at < Time.now.utc
  end

  private

  def ensure_expiration
    self.expires_at ||= Time.now.utc + self.class.default_expiration
  end

  def ensure_token
    self.token ||= SecureRandom.hex(32)
  end
end
