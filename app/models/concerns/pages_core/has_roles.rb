# frozen_string_literal: true

module PagesCore
  module HasRoles
    extend ActiveSupport::Concern

    def role?(role_name)
      role_names.include?(role_name.to_s)
    end
    alias has_role? role?

    def role_names
      roles.map(&:name)
    end

    def role_names=(names)
      self.roles = names.map do |name|
        if role?(name)
          roles.find_by(name:)
        else
          roles.new(name:)
        end
      end
    end
  end
end
