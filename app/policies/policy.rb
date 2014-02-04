class Policy
  module DefaultPolicy
    def index; false; end
    def new?; false; end
    def create?; new?; end
    def show?; false; end
    def edit?; false; end
    def update?; edit?; end
    def destroy?; edit?; end
  end

  include DefaultPolicy

  attr_reader :user, :record

  def initialize(user, record=nil)
    @user = user
    @record = record
  end

  class << self
    def for(user, object)
      if object.kind_of?(Class)
        "#{object}Policy".constantize.collection(user)
      else
        "#{object.class}Policy".constantize.member(user, object)
      end
    end

    def collection(user)
      policy = self.new(user)
      if const_defined?(:Collection)
        policy.extend const_get(:Collection)
      end
    end

    def member(user, record)
      policy = self.new(user, record)
      if const_defined?(:Member)
        policy.extend const_get(:Member)
      end
      policy
    end
  end
end
