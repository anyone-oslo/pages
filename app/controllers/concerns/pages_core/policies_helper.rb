module PagesCore
  module PoliciesHelper
    extend ActiveSupport::Concern

    included do
      helper_method :policy
    end

    module ClassMethods
      def require_authorization(object: nil, member: nil, collection: nil)
        klass = inferred_policy_class
        collection ||= %i[index new create]
        member ||= %i[show edit update destroy]

        before_action do |controller|
          object ||= controller.instance_variable_get("@#{klass.name.underscore}")

          action = params[:action].to_sym
          if collection.include?(action)
            verify_policy_with_proc(controller, klass)
          elsif member.include?(action)
            verify_policy_with_proc(controller, object)
          end
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
