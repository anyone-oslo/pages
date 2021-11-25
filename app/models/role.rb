# frozen_string_literal: true

class Role < ApplicationRecord
  belongs_to :user, touch: true
  validates :name,
            presence: true,
            uniqueness: { scope: :user_id },
            inclusion: { in: proc { Role.roles.map(&:name) } }

  RoleDefinition = Struct.new(:name, :description, :default)

  class << self
    def define(name, description, default: false)
      if roles.map(&:name).include?(name.to_s)
        raise ArgumentError, "Tried to define role :#{role}, " \
                             "but a role by that name already exists"
      else
        roles << RoleDefinition.new(name.to_s, description, default)
      end
    end

    def roles
      @roles ||= default_roles + config_roles
    end

    def names
      all.map(&:name)
    end

    protected

    def config_file
      Rails.root.join("config/roles.yml")
    end

    def config_roles
      return [] unless File.exist?(config_file)

      YAML.load_file(config_file).map do |key, opts|
        RoleDefinition.new(key.to_s, opts["description"], opts["default"])
      end
    end

    def default_roles
      [RoleDefinition.new("users", "Can manage users", false),
       RoleDefinition.new("pages", "Can manage pages", true)]
    end
  end

  def name=(new_name)
    super(new_name.to_s)
  end

  def to_s
    name.humanize
  end
end
