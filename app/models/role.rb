# frozen_string_literal: true

class Role < ActiveRecord::Base
  belongs_to :user, touch: true
  validates :name,
            presence: true,
            uniqueness: { scope: :user_id },
            inclusion: { in: proc { Role.roles.map(&:name) } }

  class << self
    def define(name, description, default: false)
      if roles.map(&:name).include?(name.to_s)
        raise ArgumentError, "Tried to define role :#{role}, " \
          "but a role by that name already exists"
      else
        roles << OpenStruct.new(
          name: name.to_s,
          description: description,
          default: default
        )
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
      Rails.root.join("config", "roles.yml")
    end

    def config_roles
      return [] unless File.exist?(config_file)

      YAML.load_file(config_file).map do |key, opts|
        OpenStruct.new(name: key.to_s,
                       description: opts["description"],
                       default: opts["default"])
      end
    end

    def default_roles
      [
        OpenStruct.new(
          name: "users", description: "Can manage users", default: false
        ),
        OpenStruct.new(
          name: "pages", description: "Can manage pages", default: true
        )
      ]
    end
  end

  def name=(new_name)
    super(new_name.to_s)
  end

  def to_s
    name.humanize
  end
end
