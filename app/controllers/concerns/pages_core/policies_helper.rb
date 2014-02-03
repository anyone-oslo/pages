module PagesCore
  module PoliciesHelper
    extend ActiveSupport::Concern

    included do
      helper_method :policy
    end

    def policy(record)
      policy_class = record.kind_of?(Class) ? "#{record}Policy" : "#{record.class}Policy"
      policy_class.constantize.new(current_user, record)
    end

    def verify_policy(record)
      unless policy(record).public_send(params[:action] + "?")
        raise PagesCore::NotAuthorized
      end
    end
  end
end