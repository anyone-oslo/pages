# frozen_string_literal: true

module PagesCore
  module AuthenticableUser
    extend ActiveSupport::Concern

    included do
      has_secure_password

      validates(:otp_secret, presence: true, if: :otp_enabled?)
      validates(
        :password,
        length: {
          minimum: 8,
          maximum: ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED,
          allow_blank: true
        }
      )

      after_initialize { |u| u.session_token ||= u.class.random_session_token }
      before_validation :update_session_token
    end

    module ClassMethods
      def authenticate(email, password:)
        User.find_by(email:).try(:authenticate, password)
      end

      def random_session_token
        SecureRandom.hex(32)
      end
    end

    def can_login?
      activated?
    end

    def recovery_codes=(codes)
      self.hashed_recovery_codes = codes.map do |c|
        BCrypt::Password.create(c, cost: 8)
      end
    end

    def use_recovery_code!(code)
      valid_hashes = hashed_recovery_codes.select do |c|
        BCrypt::Password.new(c) == code
      end
      return false unless valid_hashes.any?

      update(hashed_recovery_codes: hashed_recovery_codes - valid_hashes)
      true
    end

    private

    def update_session_token
      return unless password_digest_changed? ||
                    otp_enabled_changed?

      self.session_token = self.class.random_session_token
    end
  end
end
