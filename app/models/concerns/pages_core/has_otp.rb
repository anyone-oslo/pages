# frozen_string_literal: true

module PagesCore
  module HasOtp
    extend ActiveSupport::Concern

    included do
      validates :otp_secret, presence: true, if: :otp_enabled?
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
  end
end
