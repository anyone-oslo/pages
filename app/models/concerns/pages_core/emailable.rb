# frozen_string_literal: true

module PagesCore
  module Emailable
    extend ActiveSupport::Concern

    included do
      validates :email,
                presence: true,
                format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i },
                uniqueness: { case_sensitive: false }

      normalizes :email, with: ->(email) { email.strip }
    end
  end
end
