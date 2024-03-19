# frozen_string_literal: true

module PagesCore
  module Configuration
    class Base
      class InvalidConfigurationKey < StandardError; end

      SettingStruct = Struct.new(:type, :default)

      def self.settings
        @settings ||= {}
      end

      def self.setting(key, type, default = nil)
        settings[key] = SettingStruct.new(type, default)

        define_method key do |*args|
          args.any? ? set(key, *args) : get(key)
        end

        define_method :"#{key}=" do |value|
          set(key, value)
        end

        define_method :"#{key}?" do
          get(key) ? true : false
        end
      end

      def get(key)
        raise InvalidConfigurationKey unless setting?(key)

        if configuration.key?(key)
          configuration[key]
        else
          self.class.settings[key].default
        end
      end

      def set(key, value)
        raise InvalidConfigurationKey unless setting?(key)

        value = parse_value(key, value)
        unless valid_type?(key, value)
          raise(
            ArgumentError,
            "expected #{self.class.settings[key].type}, got #{value.class}"
          )
        end
        configuration[key] = value
      end

      protected

      def configuration
        @configuration ||= {}
      end

      def setting?(key)
        self.class.settings.key?(key)
      end

      def type_for(key)
        self.class.settings[key].type
      end

      def valid_type?(key, value)
        return true if value.nil?

        if type_for(key) == :boolean
          value.is_a?(TrueClass) || value.is_a?(FalseClass)
        else
          value.is_a?(type_for(key).to_s.camelize.constantize)
        end
      end

      def parse_value(key, value)
        if type_for(key) == :boolean
          value = true  if value == :enabled
          value = false if value == :disabled
        end
        value
      end
    end
  end
end
