# frozen_string_literal: true

module PagesCore
  module Emailable
    extend ActiveSupport::Concern

    included do
      validates :email,
                presence: true,
                format: { with: URI::MailTo::EMAIL_REGEXP },
                uniqueness: { case_sensitive: false }
      validate :email_domain_has_tld

      normalizes :email, with: lambda { |email|
        email.gsub(/[\u200B-\u200D\uFEFF]/, "").strip
      }
    end

    private

    def email_domain_has_tld
      return if email.blank?
      return unless email.to_s.match?(URI::MailTo::EMAIL_REGEXP)
      return if email.to_s.split("@", 2).last.include?(".")

      errors.add(:email, :invalid)
    end
  end
end
