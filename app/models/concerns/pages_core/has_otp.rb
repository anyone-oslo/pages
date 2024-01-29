# frozen_string_literal: true

module PagesCore
  module HasOtp
    extend ActiveSupport::Concern

    included do
      validates :otp_secret, presence: true, if: :otp_enabled?
    end

    def recovery_codes=(codes)
      self.hashed_recovery_codes = codes.map { |c| Digest::SHA2.hexdigest(c) }
    end
  end
end
