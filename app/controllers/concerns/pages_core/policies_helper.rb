module PagesCore
  module PoliciesHelper
    extend ActiveSupport::Concern

    included do
      helper_method :policy
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