module PagesCore
  module HasRoles
    extend ActiveSupport::Concern

    def role?(role_name)
      role_names.include?(role_name.to_s)
    end
    alias_method :has_role?, :role?

    def role_names
      roles.map(&:name)
    end

    def role_names=(names)
      new_roles = names.map do |name|
        if role?(name)
          roles.where(name: name).first
        else
          roles.new(name: name)
        end
      end
      self.roles = new_roles
    end
  end
end
