# frozen_string_literal: true

module PagesCore
  module Admin
    module PersistentParams
      extend ActiveSupport::Concern

      included do
        before_action :restore_persistent_params
        after_action :save_persistent_params
      end

      protected

      # Loads persistent params from user model and merges with session.
      def restore_persistent_params
        return unless current_user&.persistent_data?

        session[:persistent_params] ||= {}
        session[:persistent_params] = current_user.persistent_data.merge(
          session[:persistent_params]
        )
      end

      # Saves persistent params from session to User model if applicable.
      def save_persistent_params
        return unless current_user && session[:persistent_params]

        current_user.persistent_data = session[:persistent_params]
        current_user.save
      end

      def persistent_params(namespace)
        session[:persistent_params] ||= {}
        session[:persistent_params][namespace] ||= {}
        session[:persistent_params][namespace]
      end

      def coerce_persistent_param(value)
        case value
        when "true"
          true
        when "false"
          false
        else
          value
        end
      end

      def get_persistent_param(namespace, key, default)
        if params.key?(key)
          params[key]
        elsif persistent_params(namespace).key?(key)
          persistent_params(namespace)[key]
        else
          default
        end
      end

      # Get a persistent param
      def persistent_param(key, default = nil, options = {})
        key = key.to_s
        namespace = options[:namespace] || self.class.to_s

        value = coerce_persistent_param(
          get_persistent_param(namespace, key, default)
        )

        persistent_params(namespace)[key] = value unless value.nil?

        value
      end
    end
  end
end
