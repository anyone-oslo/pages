module PagesCore
  module HasRoles
    extend ActiveSupport::Concern

    def has_role?(role_name)
      role_names.include?(role_name.to_s)
    end

    def role_names
      self.roles.map(&:name)
    end

    def role_names=(names)
      new_roles = names.map do |name|
        if has_role?(name)
          self.roles.where(name: name).first
        else
          self.roles.new(name: name)
        end
      end
      self.roles = new_roles
    end
  end
end