# frozen_string_literal: true

module PagesCore
  module Emailable
    extend ActiveSupport::Concern

    included do
      validates :email,
                presence: true,
                format: { with: URI::MailTo::EMAIL_REGEXP },
                uniqueness: { case_sensitive: false }

      normalizes :email, with: lambda { |email|
        email.gsub(/[\u200B-\u200D\uFEFF]/, "").strip
      }
    end
  end
end
