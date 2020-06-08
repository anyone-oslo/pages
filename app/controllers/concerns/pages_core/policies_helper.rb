# frozen_string_literal: true

module PagesCore
  module PoliciesHelper
    extend ActiveSupport::Concern

    included do
      helper_method :policy
    end

    module ClassMethods
      def require_authorization(object: nil, instance: nil)
        object ||= inferred_policy_class

        before_action do |controller|
          instance_name = "@#{object.name.underscore}"
          record = instance || controller.instance_variable_get(instance_name)

          verify_policy_with_proc(controller, record || object)
        end
      end

      def inferred_policy_class
        const_get(name.demodulize.gsub(/Controller$/, "").singularize)
      end
    end

    def policy(object)
      Policy.for(current_user, object)
    end

    def verify_policy_with_proc(controller, record)
      record = controller.instance_eval(&record) if record.is_a?(Proc)
      verify_policy(record)
    end

    def verify_policy(record)
      return true if policy(record).public_send(action_name + "?")

      raise PagesCore::NotAuthorized
    end
  end
end
