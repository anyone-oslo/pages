module PagesCore
  module PoliciesHelper
    extend ActiveSupport::Concern

    included do
      helper_method :policy
    end

    module ClassMethods
      def require_authorization(collection, member, options={})
        options = {
          collection: [:index, :new, :create],
          member:     [:show, :edit, :update, :destroy]
        }.merge(options)
        before_action do |controller|
          action = params[:action].to_sym
          if options[:collection].include?(action)
            collection = controller.instance_eval(&collection) if collection.kind_of?(Proc)
            verify_policy(collection)
          elsif options[:member].include?(action)
            member = controller.instance_eval(&member) if member.kind_of?(Proc)
            verify_policy(member)
          end
        end
      end
    end

    def policy(record)
      if record.kind_of?(Class)
        "#{record}CollectionPolicy".constantize.new(current_user)
      else
        "#{record.class}Policy".constantize.new(current_user, record)
      end
    end

    def verify_policy(record)
      unless policy(record).public_send(params[:action] + "?")
        raise PagesCore::NotAuthorized
      end
    end
  end
end